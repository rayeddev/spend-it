//
//  ParentPlanViewModel.swift
//  spenditapp
//
//  Created by Group Planning Feature
//

import Foundation
import SwiftUI
internal import CoreData

// MARK: - Parent Plan View Model

@Observable
class ParentPlanViewModel {

    // MARK: - Properties

    let parentPlan: PlanEntity
    private let context: NSManagedObjectContext
    private let syncEngine: GroupSyncEngine
    private let service: GroupPlanService

    var aggregatedItems: [AggregatedItem] = []
    var childPlans: [PlanEntity] = []

    var isLoading = false
    var errorMessage: String?
    var showingError = false
    var showingDeleteConfirmation = false

    // MARK: - Computed Properties

    var totalIncome: Decimal {
        aggregatedItems
            .filter { $0.type == .income }
            .reduce(Decimal(0)) { $0 + $1.totalAmount }
    }

    var totalOutcome: Decimal {
        aggregatedItems
            .filter { $0.type == .outcome }
            .reduce(Decimal(0)) { $0 + $1.totalAmount }
    }

    var totalSavings: Decimal {
        aggregatedItems
            .filter { $0.type == .savings }
            .reduce(Decimal(0)) { $0 + $1.totalAmount }
    }

    var totalRemaining: Decimal {
        totalIncome - totalOutcome - totalSavings
    }

    var isBalanced: Bool {
        totalRemaining >= 0
    }

    var remainingColor: Color {
        if totalRemaining >= 0 {
            return .green
        } else {
            return .red
        }
    }

    var childPlanCount: Int {
        childPlans.count
    }

    var incomeItems: [AggregatedItem] {
        aggregatedItems.filter { $0.type == .income }
    }

    var outcomeItems: [AggregatedItem] {
        aggregatedItems.filter { $0.type == .outcome }
    }

    var savingsItems: [AggregatedItem] {
        aggregatedItems.filter { $0.type == .savings }
    }

    // MARK: - Initialization

    init(parentPlan: PlanEntity, context: NSManagedObjectContext) {
        self.parentPlan = parentPlan
        self.context = context
        self.syncEngine = GroupSyncEngine(context: context)
        self.service = GroupPlanService(context: context)

        // Initial load
        refreshData()

        // Observe context changes
        setupObserver()
    }

    // MARK: - Data Management

    func refreshData() {
        isLoading = true

        // Get child plans
        childPlans = service.getChildPlans(for: parentPlan)

        // Get aggregated items
        aggregatedItems = syncEngine.aggregateItemsFromChildren(parentPlan: parentPlan)

        isLoading = false
    }

    // MARK: - Observer Setup

    private func setupObserver() {
        NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            // Debounce refresh (wait 500ms)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.refreshData()
            }
        }
    }

    // MARK: - Item Breakdown

    func getBreakdown(for item: AggregatedItem) -> [(planName: String, amount: Decimal)] {
        return syncEngine.getItemBreakdown(groupKey: item.groupKey, for: parentPlan)
    }

    // MARK: - Navigation

    func getChildPlan(at index: Int) -> PlanEntity? {
        guard index < childPlans.count else { return nil }
        return childPlans[index]
    }

    // MARK: - Delete Operations

    func deleteGroup() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try service.deleteGroup(parentPlan: parentPlan)
        } catch {
            errorMessage = "Failed to delete group: \(error.localizedDescription)"
            showingError = true
        }
    }

    func deleteChildPlan(_ childPlan: PlanEntity) async {
        isLoading = true
        defer { isLoading = false }

        do {
            try service.deleteChildPlan(childPlan)
            refreshData()
        } catch {
            errorMessage = "Failed to delete child plan: \(error.localizedDescription)"
            showingError = true
        }
    }

    // MARK: - Formatting

    func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = parentPlan.currencyCode ?? "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0"
    }

    func formatCurrencyDetailed(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = parentPlan.currencyCode ?? "USD"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }

    func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    func formatMonthYear(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }

    // MARK: - Child Plan Status

    func getChildPlanStatus(_ childPlan: PlanEntity) -> (color: Color, text: String) {
        let remaining = childPlan.remainingAmount

        if remaining > 0 {
            return (.green, "Balanced")
        } else if remaining == 0 {
            return (.blue, "Exact")
        } else {
            return (.red, "Deficit")
        }
    }

    // MARK: - Cleanup

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
