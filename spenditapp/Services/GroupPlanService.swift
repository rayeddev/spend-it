//
//  GroupPlanService.swift
//  spenditapp
//
//  Created by Group Planning Feature
//

import Foundation
internal import CoreData

// MARK: - Group Plan Service

/// Service for creating and managing group plans (parent + children)
class GroupPlanService {

    // MARK: - Properties

    private let context: NSManagedObjectContext

    // MARK: - Initialization

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Create Group Plan

    /// Creates a yearly group plan with 12 monthly child plans
    /// - Parameters:
    ///   - name: Name for the parent plan
    ///   - startDate: Start date for the yearly plan
    ///   - groupType: Type of group (yearly, quarterly, custom)
    ///   - items: Array of items to add to parent (amounts will be divided among children)
    /// - Returns: The created parent plan
    /// - Throws: Error if creation fails
    func createGroupPlan(
        name: String,
        startDate: Date,
        groupType: GroupType = .yearly,
        items: [(name: String, amount: Decimal, type: ItemType)],
        currencyCode: String = Locale.current.currency?.identifier ?? "USD"
    ) throws -> PlanEntity {

        // Calculate end date based on group type
        let calendar = Calendar.current
        let endDate: Date
        switch groupType {
        case .yearly:
            endDate = calendar.date(byAdding: .year, value: 1, to: startDate)!
        case .quarterly:
            endDate = calendar.date(byAdding: .month, value: 12, to: startDate)!
        case .custom:
            endDate = calendar.date(byAdding: .year, value: 1, to: startDate)!
        }

        // Create parent plan
        let parentPlan = PlanEntity.create(
            in: context,
            name: name,
            startDate: startDate,
            endDate: calendar.date(byAdding: .day, value: -1, to: endDate)!,
            currencyCode: currencyCode
        )
        parentPlan.isGroupParent = true
        parentPlan.groupTypeEnum = groupType
        parentPlan.statusEnum = .active

        // Add items to parent plan (these are template items for aggregation)
        for item in items {
            let parentItem = PlanItemEntity.create(
                in: context,
                plan: parentPlan,
                name: item.name,
                amount: item.amount,
                type: item.type
            )
            parentItem.updateGroupKey()
        }

        // Get child plan dates
        let childDates = groupType.childPlanDates(startingFrom: startDate)
        let childCount = childDates.count

        guard childCount > 0 else {
            throw GroupPlanError.invalidDateRange
        }

        // Create child plans
        for (index, dates) in childDates.enumerated() {
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MMMM yyyy"
            let childName = monthFormatter.string(from: dates.start)

            let childPlan = PlanEntity.create(
                in: context,
                name: childName,
                startDate: dates.start,
                endDate: dates.end,
                currencyCode: currencyCode
            )
            childPlan.statusEnum = .active

            // Create group relationship
            _ = PlanGroupEntity.create(
                in: context,
                parentPlan: parentPlan,
                childPlan: childPlan,
                sequenceOrder: Int16(index)
            )

            // Clone items from parent to child with divided amounts
            for item in items {
                let dividedAmount = item.amount / Decimal(childCount)
                let childItem = PlanItemEntity(context: context)
                childItem.id = UUID()
                childItem.plan = childPlan
                childItem.name = item.name
                childItem.amountDecimal = dividedAmount
                childItem.type = item.type.rawValue
                childItem.isFrozen = false
                childItem.sortOrder = 0
                childItem.createdAt = Date()
                childItem.updatedAt = Date()
                childItem.updateGroupKey()

                // Find parent item ID for sourceItemId
                if let parentItem = parentPlan.sortedItems.first(where: {
                    $0.name == item.name && $0.typeEnum == item.type
                }) {
                    childItem.sourceItemId = parentItem.id
                }
            }
        }

        // Save context
        try context.save()

        return parentPlan
    }

    // MARK: - Get Child Plans

    /// Get all child plans for a parent plan, sorted by sequence order
    func getChildPlans(for parentPlan: PlanEntity) -> [PlanEntity] {
        return PlanGroupEntity.getChildPlans(for: parentPlan, in: context)
    }

    /// Get parent plan for a child plan
    func getParentPlan(for childPlan: PlanEntity) -> PlanEntity? {
        return PlanGroupEntity.getParentPlan(for: childPlan, in: context)
    }

    // MARK: - Delete Group

    /// Delete a group plan (parent and all children)
    /// - Parameter parentPlan: The parent plan to delete
    /// - Throws: Error if deletion fails
    func deleteGroup(parentPlan: PlanEntity) throws {
        guard parentPlan.isGroupParent else {
            throw GroupPlanError.notAGroupParent
        }

        // Get all child plans before deletion
        let childPlans = getChildPlans(for: parentPlan)

        // Delete all group relationships
        try PlanGroupEntity.deleteGroupRelationships(for: parentPlan, in: context)

        // Delete all child plans (this will cascade delete their items)
        for childPlan in childPlans {
            context.delete(childPlan)
        }

        // Delete parent plan (this will cascade delete its items)
        context.delete(parentPlan)

        // Save context
        try context.save()
    }

    /// Delete a single child plan from a group
    /// - Parameter childPlan: The child plan to delete
    /// - Throws: Error if deletion fails
    func deleteChildPlan(_ childPlan: PlanEntity) throws {
        // Delete group relationship
        try PlanGroupEntity.deleteGroupRelationships(for: childPlan, in: context)

        // Delete the child plan
        context.delete(childPlan)

        // Save context
        try context.save()
    }

    // MARK: - Validation

    /// Check if a plan is part of a group
    func isPartOfGroup(plan: PlanEntity) -> Bool {
        return PlanGroupEntity.isPartOfGroup(plan: plan, in: context)
    }

    /// Validate group plan parameters
    func validateGroupPlan(
        name: String,
        startDate: Date,
        items: [(name: String, amount: Decimal, type: ItemType)]
    ) throws {
        // Check name is not empty
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw GroupPlanError.invalidName
        }

        // Check we have at least one item
        guard !items.isEmpty else {
            throw GroupPlanError.noItems
        }

        // Check start date is not in the past (allow same day)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let planStartDay = calendar.startOfDay(for: startDate)
        guard planStartDay >= today else {
            throw GroupPlanError.invalidDateRange
        }
    }

    // MARK: - Plan Count

    /// Get the total number of child plans for a parent
    func getChildPlanCount(for parentPlan: PlanEntity) -> Int {
        return getChildPlans(for: parentPlan).count
    }
}

// MARK: - Group Plan Errors

enum GroupPlanError: LocalizedError {
    case invalidName
    case invalidDateRange
    case noItems
    case notAGroupParent
    case childPlanNotFound

    var errorDescription: String? {
        switch self {
        case .invalidName:
            return "Plan name cannot be empty"
        case .invalidDateRange:
            return "Invalid date range for group plan"
        case .noItems:
            return "Group plan must have at least one item"
        case .notAGroupParent:
            return "This plan is not a group parent"
        case .childPlanNotFound:
            return "Child plan not found in group"
        }
    }
}
