//
//  PlansListView.swift
//  spenditapp
//
//  Created by RAYED AL NOOM on 2025-12-19.
//

import SwiftUI
internal import CoreData

// MARK: - Plans List View

struct PlansListView: View {

    // MARK: - Properties

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \PlanEntity.startDate, ascending: false)
        ],
        animation: .default
    )
    private var plans: FetchedResults<PlanEntity>

    @State private var showingNewPlanSheet = false
    @State private var showingSettings = false
    @State private var selectedPlan: PlanEntity?

    // MARK: - Computed Properties

    private var activePlans: [PlanEntity] {
        plans.filter { $0.statusEnum == .active }
    }

    private var upcomingPlans: [PlanEntity] {
        plans.filter {
            $0.statusEnum == .draft ||
            ($0.startDate ?? Date()) > Date()
        }
    }

    private var historicalPlans: [PlanEntity] {
        plans.filter {
            $0.statusEnum == .completed || $0.statusEnum == .archived
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                if plans.isEmpty {
                    emptyState
                } else {
                    plansList
                }
            }
            .navigationTitle("SpendIt")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                            .accessibilityLabel("Settings")
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewPlanSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .accessibilityLabel("Create new plan")
                    }
                }
            }
            .sheet(isPresented: $showingNewPlanSheet) {
                NewPlanView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 64))
                .foregroundStyle(.blue.gradient)

            Text("No Plans Yet")
                .font(.title2.bold())

            Text("Create your first spending plan to get started")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showingNewPlanSheet = true
            } label: {
                Label("Create Plan", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 8)
        }
        .padding()
    }

    // MARK: - Plans List

    private var plansList: some View {
        List {
            // Active Plans
            if !activePlans.isEmpty {
                Section {
                    ForEach(activePlans) { plan in
                        NavigationLink(value: plan) {
                            PlanRowView(plan: plan)
                        }
                    }
                } header: {
                    Text("ACTIVE")
                }
            }

            // Upcoming Plans
            if !upcomingPlans.isEmpty {
                Section {
                    ForEach(upcomingPlans) { plan in
                        NavigationLink(value: plan) {
                            PlanRowView(plan: plan)
                        }
                    }
                } header: {
                    Text("UPCOMING")
                }
            }

            // Historical Plans
            if !historicalPlans.isEmpty {
                Section {
                    ForEach(historicalPlans) { plan in
                        NavigationLink(value: plan) {
                            PlanRowView(plan: plan)
                        }
                    }
                    .onDelete { indexSet in
                        deleteHistoricalPlans(at: indexSet)
                    }
                } header: {
                    Text("HISTORY")
                }
            }
        }
        .navigationDestination(for: PlanEntity.self) { plan in
            PlanDetailView(plan: plan)
        }
    }

    // MARK: - Actions

    private func deleteHistoricalPlans(at offsets: IndexSet) {
        HapticManager.shared.warning()

        withAnimation {
            offsets.forEach { index in
                let plan = historicalPlans[index]
                viewContext.delete(plan)
            }

            do {
                try viewContext.save()
                HapticManager.shared.success()
            } catch {
                print("Error deleting plan: \(error)")
            }
        }
    }
}

// MARK: - Plan Row View

struct PlanRowView: View {

    @ObservedObject var plan: PlanEntity

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(plan.name ?? "Unnamed Plan")
                    .font(.headline)

                Spacer()

                if plan.isRecurring {
                    Image(systemName: "repeat")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                Text(dateRangeText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(remainingText)
                    .font(.subheadline.bold())
                    .foregroundStyle(plan.isBalanced ? .green : .red)
            }

            // Mini summary
            HStack(spacing: 16) {
                SummaryMiniItem(
                    label: "Income",
                    value: plan.totalIncome,
                    color: .green,
                    currencyCode: plan.currencyCode ?? "USD"
                )

                SummaryMiniItem(
                    label: "Expenses",
                    value: plan.totalOutcome,
                    color: .red,
                    currencyCode: plan.currencyCode ?? "USD"
                )

                SummaryMiniItem(
                    label: "Savings",
                    value: plan.totalSavings,
                    color: .blue,
                    currencyCode: plan.currencyCode ?? "USD"
                )
            }
            .font(.caption)
        }
        .padding(.vertical, 4)
    }

    private var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        guard let start = plan.startDate, let end = plan.endDate else {
            return "No dates"
        }

        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }

    private var remainingText: String {
        let remaining = plan.remainingAmount
        let currencyCode = plan.currencyCode ?? "USD"
        return "Remaining: \(CurrencyFormatter.shared.string(from: remaining, currencyCode: currencyCode))"
    }
}

// MARK: - Summary Mini Item

struct SummaryMiniItem: View {
    let label: String
    let value: Decimal
    let color: Color
    let currencyCode: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .foregroundStyle(.secondary)
            Text(CurrencyFormatter.shared.abbreviatedString(from: value, currencyCode: currencyCode))
                .foregroundStyle(color)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Preview

#Preview {
    PlansListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
