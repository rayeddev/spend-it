//
//  GroupSyncEngine.swift
//  spenditapp
//
//  Created by Group Planning Feature
//

import Foundation
internal import CoreData

// MARK: - Aggregated Item

/// Represents an aggregated item from multiple child plans
struct AggregatedItem: Identifiable {
    let id = UUID()
    let name: String
    let type: ItemType
    let totalAmount: Decimal
    let childItems: [PlanItemEntity]
    let groupKey: String

    /// Average amount across child plans
    var averageAmount: Decimal {
        guard !childItems.isEmpty else { return 0 }
        return totalAmount / Decimal(childItems.count)
    }

    /// Number of child plans that have this item
    var planCount: Int {
        childItems.count
    }

    /// Check if all child plans have this item (vs. some)
    var isInAllChildren: Bool {
        // This would need context to know total child count
        // For now, we return false if any child is missing it
        return planCount > 0
    }
}

// MARK: - Group Sync Engine

/// Engine for synchronizing data between parent and child plans in a group
class GroupSyncEngine {

    // MARK: - Properties

    private let context: NSManagedObjectContext

    // MARK: - Initialization

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Aggregation

    /// Aggregate all items from child plans and return aggregated items
    /// - Parameter parentPlan: The parent plan to aggregate for
    /// - Returns: Array of aggregated items
    func aggregateItemsFromChildren(parentPlan: PlanEntity) -> [AggregatedItem] {
        guard parentPlan.isGroupParent else {
            print("Warning: Attempting to aggregate from non-group parent plan")
            return []
        }

        // Get all child plans
        let childPlans = PlanGroupEntity.getChildPlans(for: parentPlan, in: context)

        guard !childPlans.isEmpty else {
            return []
        }

        // Group items by groupKey
        let grouped = matchItems(across: childPlans)

        // Create aggregated items
        var aggregatedItems: [AggregatedItem] = []

        for (groupKey, items) in grouped {
            // Extract name and type from groupKey
            let components = groupKey.split(separator: "|")
            guard components.count == 2,
                  let name = components.first,
                  let typeRawValue = components.last,
                  let type = ItemType(rawValue: String(typeRawValue)) else {
                continue
            }

            // Calculate total amount
            let totalAmount = items.reduce(Decimal(0)) { sum, item in
                sum + (item.amountDecimal ?? 0)
            }

            let aggregatedItem = AggregatedItem(
                name: String(name).capitalized,
                type: type,
                totalAmount: totalAmount,
                childItems: items,
                groupKey: groupKey
            )

            aggregatedItems.append(aggregatedItem)
        }

        // Sort by type (income, outcome, savings) then by name
        let typeOrder: [ItemType] = [.income, .outcome, .savings]
        aggregatedItems.sort { item1, item2 in
            if item1.type == item2.type {
                return item1.name < item2.name
            }
            let index1 = typeOrder.firstIndex(of: item1.type) ?? 0
            let index2 = typeOrder.firstIndex(of: item2.type) ?? 0
            return index1 < index2
        }

        return aggregatedItems
    }

    /// Match items across multiple plans using groupKey
    /// - Parameter plans: Array of child plans
    /// - Returns: Dictionary mapping groupKey to array of items
    private func matchItems(across plans: [PlanEntity]) -> [String: [PlanItemEntity]] {
        var grouped: [String: [PlanItemEntity]] = [:]

        for plan in plans {
            for item in plan.sortedItems where !item.isFrozen {
                // Ensure groupKey is set
                if item.groupKey == nil || item.groupKey?.isEmpty == true {
                    item.updateGroupKey()
                }

                let key = item.groupKey ?? item.computedGroupKey
                grouped[key, default: []].append(item)
            }
        }

        return grouped
    }

    // MARK: - Aggregated Calculations

    /// Calculate aggregated totals for a parent plan
    /// - Parameter parentPlan: The parent plan
    /// - Returns: Tuple of (totalIncome, totalOutcome, totalSavings, remaining)
    func calculateAggregatedTotals(for parentPlan: PlanEntity) -> (income: Decimal, outcome: Decimal, savings: Decimal, remaining: Decimal) {
        let aggregatedItems = aggregateItemsFromChildren(parentPlan: parentPlan)

        let income = aggregatedItems
            .filter { $0.type == .income }
            .reduce(Decimal(0)) { $0 + $1.totalAmount }

        let outcome = aggregatedItems
            .filter { $0.type == .outcome }
            .reduce(Decimal(0)) { $0 + $1.totalAmount }

        let savings = aggregatedItems
            .filter { $0.type == .savings }
            .reduce(Decimal(0)) { $0 + $1.totalAmount }

        let remaining = income - outcome - savings

        return (income, outcome, savings, remaining)
    }

    // MARK: - Sync Child to Parent

    /// Sync changes from child plan to parent (update aggregation)
    /// This doesn't modify the parent items directly, but triggers a recalculation
    /// - Parameter childPlan: The child plan that was modified
    func syncChildToParent(childPlan: PlanEntity) throws {
        // Get parent plan
        guard let parentPlan = PlanGroupEntity.getParentPlan(for: childPlan, in: context) else {
            print("No parent plan found for child plan")
            return
        }

        // Update parent's updatedAt timestamp to trigger observers
        parentPlan.updatedAt = Date()

        try context.save()
    }

    // MARK: - Breakdown by Month

    /// Get breakdown of a specific item across all child plans
    /// - Parameters:
    ///   - groupKey: The groupKey of the item to break down
    ///   - parentPlan: The parent plan
    /// - Returns: Array of (planName, amount) tuples
    func getItemBreakdown(groupKey: String, for parentPlan: PlanEntity) -> [(planName: String, amount: Decimal)] {
        let childPlans = PlanGroupEntity.getChildPlans(for: parentPlan, in: context)

        var breakdown: [(planName: String, amount: Decimal)] = []

        for childPlan in childPlans {
            let matchingItems = childPlan.sortedItems.filter {
                !$0.isFrozen && ($0.groupKey == groupKey || $0.computedGroupKey == groupKey)
            }

            let totalForPlan = matchingItems.reduce(Decimal(0)) { $0 + ($1.amountDecimal ?? 0) }

            breakdown.append((
                planName: childPlan.name ?? "Unknown",
                amount: totalForPlan
            ))
        }

        return breakdown
    }

    // MARK: - Update All GroupKeys

    /// Update groupKeys for all items in all plans (useful for migration or fixing data)
    func updateAllGroupKeys() throws {
        let fetchRequest: NSFetchRequest<PlanItemEntity> = PlanItemEntity.fetchRequest()

        do {
            let allItems = try context.fetch(fetchRequest)
            for item in allItems {
                item.updateGroupKey()
            }
            try context.save()
        } catch {
            print("Error updating group keys: \(error)")
            throw error
        }
    }
}

// MARK: - Extensions

extension PlanEntity {

    /// Get aggregated items if this is a group parent
    func getAggregatedItems(using syncEngine: GroupSyncEngine) -> [AggregatedItem] {
        guard isGroupParent else { return [] }
        return syncEngine.aggregateItemsFromChildren(parentPlan: self)
    }

    /// Get aggregated totals if this is a group parent
    func getAggregatedTotals(using syncEngine: GroupSyncEngine) -> (income: Decimal, outcome: Decimal, savings: Decimal, remaining: Decimal) {
        guard isGroupParent else {
            return (totalIncome, totalOutcome, totalSavings, remainingAmount)
        }
        return syncEngine.calculateAggregatedTotals(for: self)
    }
}
