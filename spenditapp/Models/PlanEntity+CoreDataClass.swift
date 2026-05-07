//
//  PlanEntity+CoreDataClass.swift
//  spenditapp
//
//  Created by RAYED AL NOOM on 2025-12-19.
//

import Foundation
internal import CoreData

@objc(PlanEntity)
 class PlanEntity: NSManagedObject {

    // MARK: - Computed Properties

    /// All items associated with this plan, sorted by type and sort order
    var sortedItems: [PlanItemEntity] {
        let itemsSet = items as? Set<PlanItemEntity> ?? []
        return itemsSet.sorted { (item1, item2) in
            if item1.typeEnum == item2.typeEnum {
                return item1.sortOrder < item2.sortOrder
            }
            // Sort by type order: income, outcome, savings
            let typeOrder: [ItemType] = [.income, .outcome, .savings]
            let index1 = typeOrder.firstIndex(of: item1.typeEnum) ?? 0
            let index2 = typeOrder.firstIndex(of: item2.typeEnum) ?? 0
            return index1 < index2
        }
    }

    /// Items filtered by type
    func items(ofType type: ItemType) -> [PlanItemEntity] {
        sortedItems.filter { $0.typeEnum == type }
    }

    // MARK: - Financial Calculations

    /// Total of all active (non-frozen) income items
    var totalIncome: Decimal {
        items(ofType: .income)
            .filter { !$0.isFrozen }
            .reduce(Decimal(0)) { $0 + ($1.amountDecimal ?? 0) }
    }

    /// Total of all active (non-frozen) outcome items
    var totalOutcome: Decimal {
        items(ofType: .outcome)
            .filter { !$0.isFrozen }
            .reduce(Decimal(0)) { $0 + ($1.amountDecimal ?? 0) }
    }

    /// Total of all active (non-frozen) savings items
    var totalSavings: Decimal {
        items(ofType: .savings)
            .filter { !$0.isFrozen }
            .reduce(Decimal(0)) { $0 + ($1.amountDecimal ?? 0) }
    }

    /// Remaining amount after outcome and savings
    var remainingAmount: Decimal {
        totalIncome - totalOutcome - totalSavings
    }

    /// Indicates if plan is balanced (remaining >= 0)
    var isBalanced: Bool {
        remainingAmount >= 0
    }

    /// Amount currently frozen (not in calculations) for outcomes
    var frozenOutcomeTotal: Decimal {
        items(ofType: .outcome)
            .filter { $0.isFrozen }
            .reduce(Decimal(0)) { $0 + ($1.amountDecimal ?? 0) }
    }

    /// Total frozen across all types
    var totalFrozen: Decimal {
        sortedItems
            .filter { $0.isFrozen }
            .reduce(Decimal(0)) { $0 + ($1.amountDecimal ?? 0) }
    }

    // MARK: - Enum Helpers

    var statusEnum: PlanStatus {
        get {
            PlanStatus(rawValue: status ?? PlanStatus.draft.rawValue) ?? .draft
        }
        set {
            status = newValue.rawValue
        }
    }

    var recurrenceTypeEnum: RecurrenceType? {
        get {
            guard let type = recurrenceType else { return nil }
            return RecurrenceType(rawValue: type)
        }
        set {
            recurrenceType = newValue?.rawValue
        }
    }

    var groupTypeEnum: GroupType? {
        get {
            guard let type = groupType else { return nil }
            return GroupType(rawValue: type)
        }
        set {
            groupType = newValue?.rawValue
        }
    }

    // MARK: - Convenience

    /// Creates a new plan with default values
    static func create(in context: NSManagedObjectContext,
                      name: String,
                      startDate: Date,
                      endDate: Date,
                      currencyCode: String = Locale.current.currency?.identifier ?? "USD") -> PlanEntity {
        let plan = PlanEntity(context: context)
        plan.id = UUID()
        plan.name = name
        plan.startDate = startDate
        plan.endDate = endDate
        plan.currencyCode = currencyCode
        plan.status = PlanStatus.draft.rawValue
        plan.isRecurring = false
        plan.createdAt = Date()
        plan.updatedAt = Date()
        return plan
    }

    /// Clone this plan with new dates
    func clone(in context: NSManagedObjectContext,
               name: String? = nil,
               startDate: Date? = nil,
               endDate: Date? = nil) -> PlanEntity {
        let newPlan = PlanEntity(context: context)
        newPlan.id = UUID()
        newPlan.name = name ?? "\(self.name ?? "Plan") (Copy)"
        newPlan.startDate = startDate ?? self.startDate
        newPlan.endDate = endDate ?? self.endDate
        newPlan.currencyCode = self.currencyCode
        newPlan.status = PlanStatus.draft.rawValue
        newPlan.isRecurring = self.isRecurring
        newPlan.recurrenceType = self.recurrenceType
        newPlan.parentPlanId = self.id
        newPlan.createdAt = Date()
        newPlan.updatedAt = Date()

        // Clone all items with frozen state reset
        for item in sortedItems {
            _ = item.clone(to: newPlan, in: context)
        }

        return newPlan
    }
}
