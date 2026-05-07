//
//  GroupPlanViewModel.swift
//  spenditapp
//
//  Created by Group Planning Feature
//

import Foundation
import SwiftUI
internal import CoreData

// MARK: - Item for Creation

/// Temporary item structure for group plan creation
struct GroupPlanItem: Identifiable {
    let id = UUID()
    var name: String
    var amount: Decimal
    var type: ItemType
    var icon: String?
    var color: String?
}

// MARK: - Group Plan View Model

@Observable
class GroupPlanViewModel {

    // MARK: - Properties

    var planName: String = ""
    var startDate: Date = Date()
    var groupType: GroupType = .yearly
    var currencyCode: String = Locale.current.currency?.identifier ?? "USD"

    var incomeItems: [GroupPlanItem] = []
    var outcomeItems: [GroupPlanItem] = []
    var savingsItems: [GroupPlanItem] = []

    var isCreating = false
    var errorMessage: String?
    var showingError = false

    // MARK: - Computed Properties

    var totalIncome: Decimal {
        incomeItems.reduce(Decimal(0)) { $0 + $1.amount }
    }

    var totalOutcome: Decimal {
        outcomeItems.reduce(Decimal(0)) { $0 + $1.amount }
    }

    var totalSavings: Decimal {
        savingsItems.reduce(Decimal(0)) { $0 + $1.amount }
    }

    var totalRemaining: Decimal {
        totalIncome - totalOutcome - totalSavings
    }

    var isBalanced: Bool {
        totalRemaining >= 0
    }

    var allItems: [(name: String, amount: Decimal, type: ItemType)] {
        var items: [(String, Decimal, ItemType)] = []

        for item in incomeItems {
            items.append((item.name, item.amount, .income))
        }
        for item in outcomeItems {
            items.append((item.name, item.amount, .outcome))
        }
        for item in savingsItems {
            items.append((item.name, item.amount, .savings))
        }

        return items
    }

    var childPlanCount: Int {
        groupType.childPlanCount
    }

    var isValid: Bool {
        !planName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !allItems.isEmpty
    }

    // MARK: - Initialization

    init() {
        // Set default start date to first day of next month
        let calendar = Calendar.current
        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: Date()),
           let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: nextMonth)) {
            self.startDate = firstDayOfMonth
        }
    }

    // MARK: - Item Management

    func addIncomeItem(name: String = "", amount: Decimal = 0) {
        let item = GroupPlanItem(name: name, amount: amount, type: .income)
        incomeItems.append(item)
    }

    func addOutcomeItem(name: String = "", amount: Decimal = 0) {
        let item = GroupPlanItem(name: name, amount: amount, type: .outcome)
        outcomeItems.append(item)
    }

    func addSavingsItem(name: String = "", amount: Decimal = 0) {
        let item = GroupPlanItem(name: name, amount: amount, type: .savings)
        savingsItems.append(item)
    }

    func deleteItems(ofType type: ItemType, at offsets: IndexSet) {
        switch type {
        case .income:
            incomeItems.remove(atOffsets: offsets)
        case .outcome:
            outcomeItems.remove(atOffsets: offsets)
        case .savings:
            savingsItems.remove(atOffsets: offsets)
        }
    }

    func updateItem(_ item: GroupPlanItem, name: String, amount: Decimal) {
        if let index = incomeItems.firstIndex(where: { $0.id == item.id }) {
            incomeItems[index].name = name
            incomeItems[index].amount = amount
        } else if let index = outcomeItems.firstIndex(where: { $0.id == item.id }) {
            outcomeItems[index].name = name
            outcomeItems[index].amount = amount
        } else if let index = savingsItems.firstIndex(where: { $0.id == item.id }) {
            savingsItems[index].name = name
            savingsItems[index].amount = amount
        }
    }

    // MARK: - Validation

    func validate() -> Bool {
        // Clear previous error
        errorMessage = nil

        // Check plan name
        guard !planName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Plan name is required"
            showingError = true
            return false
        }

        // Check we have at least one item
        guard !allItems.isEmpty else {
            errorMessage = "Add at least one item to your plan"
            showingError = true
            return false
        }

        // Check start date is not too far in the past
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let planStartDay = calendar.startOfDay(for: startDate)

        guard planStartDay >= today || calendar.dateComponents([.day], from: planStartDay, to: today).day! <= 7 else {
            errorMessage = "Start date cannot be more than 7 days in the past"
            showingError = true
            return false
        }

        return true
    }

    // MARK: - Create Group Plan

    @MainActor
    func createGroup(in context: NSManagedObjectContext) async throws -> PlanEntity {
        guard validate() else {
            throw GroupPlanError.invalidName
        }

        isCreating = true
        defer { isCreating = false }

        let service = GroupPlanService(context: context)

        do {
            let parentPlan = try service.createGroupPlan(
                name: planName,
                startDate: startDate,
                groupType: groupType,
                items: allItems,
                currencyCode: currencyCode
            )

            return parentPlan
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
            throw error
        }
    }

    // MARK: - Helper Methods

    func reset() {
        planName = ""
        incomeItems.removeAll()
        outcomeItems.removeAll()
        savingsItems.removeAll()
        errorMessage = nil
        showingError = false

        // Reset start date to first day of next month
        let calendar = Calendar.current
        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: Date()),
           let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: nextMonth)) {
            self.startDate = firstDayOfMonth
        }
    }

    /// Get preview of child plan for a specific month
    func getChildPlanPreview(for index: Int) -> (name: String, startDate: Date, endDate: Date)? {
        let childDates = groupType.childPlanDates(startingFrom: startDate)

        guard index < childDates.count else { return nil }

        let dates = childDates[index]
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM yyyy"
        let name = monthFormatter.string(from: dates.start)

        return (name, dates.start, dates.end)
    }

    /// Get divided amount for an item in each child plan
    func getDividedAmount(for amount: Decimal) -> Decimal {
        let count = Decimal(groupType.childPlanCount)
        return count > 0 ? amount / count : 0
    }
}
