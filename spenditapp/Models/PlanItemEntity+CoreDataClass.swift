//
//  PlanItemEntity+CoreDataClass.swift
//  spenditapp
//
//  Created by RAYED AL NOOM on 2025-12-19.
//

import Foundation
internal import CoreData

@objc(PlanItemEntity)
 class PlanItemEntity: NSManagedObject {

    // MARK: - Decimal Amount Helper

    /// Convert stored NSDecimalNumber to Decimal
    var amountDecimal: Decimal? {
        get {
            amount as Decimal?
        }
        set {
            amount = newValue.map { NSDecimalNumber(decimal: $0) }
        }
    }

    // MARK: - Type Enum Helper

    var typeEnum: ItemType {
        get {
            ItemType(rawValue: type ?? ItemType.outcome.rawValue) ?? .outcome
        }
        set {
            type = newValue.rawValue
        }
    }

    // MARK: - Group Key Helper

    /// Computed group key for matching items across plans
    /// Format: "itemname|type"
    var computedGroupKey: String {
        let itemName = name?.lowercased().trimmingCharacters(in: .whitespaces) ?? ""
        let itemType = type ?? ""
        return "\(itemName)|\(itemType)"
    }

    /// Update the stored groupKey to match computed value
    func updateGroupKey() {
        groupKey = computedGroupKey
    }

    // MARK: - Convenience

    /// Creates a new plan item with default values
    static func create(in context: NSManagedObjectContext,
                      plan: PlanEntity,
                      name: String,
                      amount: Decimal,
                      type: ItemType,
                      sortOrder: Int16? = nil) -> PlanItemEntity {
        let item = PlanItemEntity(context: context)
        item.id = UUID()
        item.plan = plan
        item.name = name
        item.amountDecimal = amount
        item.type = type.rawValue
        item.isFrozen = false
        item.createdAt = Date()
        item.updatedAt = Date()

        // Auto-assign sort order if not provided
        if let sortOrder = sortOrder {
            item.sortOrder = sortOrder
        } else {
            let existingItems = plan.items(ofType: type)
            item.sortOrder = Int16((existingItems.map { $0.sortOrder }.max() ?? -1) + 1)
        }

        // Set group key for aggregation
        item.updateGroupKey()

        return item
    }

    /// Clone this item to another plan
    func clone(to plan: PlanEntity, in context: NSManagedObjectContext) -> PlanItemEntity {
        let newItem = PlanItemEntity(context: context)
        newItem.id = UUID()
        newItem.plan = plan
        newItem.name = self.name
        newItem.amount = self.amount
        newItem.type = self.type
        newItem.isFrozen = false  // Reset frozen state on clone
        newItem.sortOrder = self.sortOrder
        newItem.icon = self.icon
        newItem.color = self.color
        newItem.notes = self.notes
        newItem.createdAt = Date()
        newItem.updatedAt = Date()
        newItem.updateGroupKey()  // Set group key for aggregation
        return newItem
    }

    /// Clone this item for group plan child with source tracking
    func cloneForGroup(to plan: PlanEntity, dividedAmount: Decimal, in context: NSManagedObjectContext) -> PlanItemEntity {
        let newItem = PlanItemEntity(context: context)
        newItem.id = UUID()
        newItem.plan = plan
        newItem.name = self.name
        newItem.amountDecimal = dividedAmount  // Use divided amount
        newItem.type = self.type
        newItem.isFrozen = false
        newItem.sortOrder = self.sortOrder
        newItem.icon = self.icon
        newItem.color = self.color
        newItem.notes = self.notes
        newItem.sourceItemId = self.id  // Track source for group sync
        newItem.createdAt = Date()
        newItem.updatedAt = Date()
        newItem.updateGroupKey()
        return newItem
    }

    /// Format amount as currency string
    func formattedAmount(currencyCode: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        let decimalAmount = amountDecimal ?? 0
        return formatter.string(from: NSDecimalNumber(decimal: decimalAmount)) ?? "$0.00"
    }
}
