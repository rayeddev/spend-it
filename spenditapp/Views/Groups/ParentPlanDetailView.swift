//
//  ParentPlanDetailView.swift
//  spenditapp
//
//  Created by Group Planning Feature
//

import SwiftUI
internal import CoreData

// MARK: - Parent Plan Detail View

struct ParentPlanDetailView: View {

    // MARK: - Properties

    @ObservedObject var parentPlan: PlanEntity
    @State private var viewModel: ParentPlanViewModel

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab: ItemType = .outcome
    @State private var expandedItems: Set<UUID> = []
    @State private var selectedChildPlan: PlanEntity?
    @State private var navigateToChild = false

    // MARK: - Initialization

    init(parentPlan: PlanEntity) {
        self.parentPlan = parentPlan
        _viewModel = State(initialValue: ParentPlanViewModel(
            parentPlan: parentPlan,
            context: PersistenceController.shared.container.viewContext
        ))
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            // Gradient background
            AdaptiveGradientView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Parent plan summary
                parentSummaryCard

                // Custom tab picker
                CustomTabPicker(selection: $selectedTab)

                // Aggregated items list
                aggregatedItemsList
                    .padding(.bottom, 160) // Space for child plans card
            }

            // Child plans card at bottom
            childPlansCard
        }
        .navigationTitle(parentPlan.name ?? "Group Plan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(role: .destructive) {
                        viewModel.showingDeleteConfirmation = true
                    } label: {
                        Label("Delete Group", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Delete Group Plan", isPresented: $viewModel.showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteGroup()
                    dismiss()
                }
            }
        } message: {
            Text("This will delete the parent plan and all \(viewModel.childPlanCount) child plans. This action cannot be undone.")
        }
        .alert("Error", isPresented: $viewModel.showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(12)
            }
        }
        .navigationDestination(isPresented: $navigateToChild) {
            if let childPlan = selectedChildPlan {
                PlanDetailView(plan: childPlan)
            }
        }
    }

    // MARK: - Parent Summary Card

    private var parentSummaryCard: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "calendar.badge.plus")
                    .foregroundStyle(.blue)
                Text("Group Plan Summary")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.childPlanCount) plans")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Financial Summary
            HStack(spacing: 20) {
                SummaryItem(
                    title: "Income",
                    amount: viewModel.formatCurrency(viewModel.totalIncome),
                    color: .green
                )

                Divider()
                    .frame(height: 40)

                SummaryItem(
                    title: "Expenses",
                    amount: viewModel.formatCurrency(viewModel.totalOutcome),
                    color: .red
                )

                Divider()
                    .frame(height: 40)

                SummaryItem(
                    title: "Savings",
                    amount: viewModel.formatCurrency(viewModel.totalSavings),
                    color: .blue
                )
            }

            Divider()

            // Remaining
            HStack {
                Text("Total Remaining")
                    .font(.headline)
                Spacer()
                Text(viewModel.formatCurrency(viewModel.totalRemaining))
                    .font(.title2.bold())
                    .foregroundStyle(viewModel.remainingColor)
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(16)
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Aggregated Items List

    private var aggregatedItemsList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                let items = filteredItems

                if items.isEmpty {
                    emptyStateView
                } else {
                    ForEach(items) { item in
                        AggregatedItemCard(
                            item: item,
                            isExpanded: expandedItems.contains(item.id),
                            viewModel: viewModel
                        ) {
                            toggleExpansion(for: item)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }

    private var filteredItems: [AggregatedItem] {
        switch selectedTab {
        case .income:
            return viewModel.incomeItems
        case .outcome:
            return viewModel.outcomeItems
        case .savings:
            return viewModel.savingsItems
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No \(selectedTab.displayName.lowercased()) items")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    // MARK: - Child Plans Card

    private var childPlansCard: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Child Plans")
                    .font(.headline)
                Spacer()
                Button("Refresh") {
                    viewModel.refreshData()
                }
                .font(.caption)
                .foregroundStyle(.blue)
            }
            .padding()
            .background(.regularMaterial)

            Divider()

            // Child plans list
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.childPlans, id: \.id) { childPlan in
                        ChildPlanCard(childPlan: childPlan, viewModel: viewModel) {
                            selectedChildPlan = childPlan
                            navigateToChild = true
                        }
                    }
                }
                .padding()
            }
            .frame(height: 120)
            .background(.regularMaterial)
        }
        .background(.regularMaterial)
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
    }

    // MARK: - Helpers

    private func toggleExpansion(for item: AggregatedItem) {
        withAnimation {
            if expandedItems.contains(item.id) {
                expandedItems.remove(item.id)
            } else {
                expandedItems.insert(item.id)
            }
        }
        HapticManager.shared.lightImpact()
    }
}

// MARK: - Summary Item

struct SummaryItem: View {
    let title: String
    let amount: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(amount)
                .font(.headline)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Aggregated Item Card

struct AggregatedItemCard: View {
    let item: AggregatedItem
    let isExpanded: Bool
    let viewModel: ParentPlanViewModel
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main row
            Button(action: onTap) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.headline)

                        Text("\(item.planCount) of \(viewModel.childPlanCount) plans")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(viewModel.formatCurrency(item.totalAmount))
                            .font(.title3.bold())
                            .foregroundStyle(itemColor)

                        Text("Avg: \(viewModel.formatCurrencyDetailed(item.averageAmount))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                        .imageScale(.small)
                }
                .padding()
            }
            .buttonStyle(.plain)

            // Expanded breakdown
            if isExpanded {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Breakdown by Plan")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 4)

                    let breakdown = viewModel.getBreakdown(for: item)
                    ForEach(Array(breakdown.enumerated()), id: \.offset) { _, entry in
                        HStack {
                            Text(entry.planName)
                                .font(.caption)
                            Spacer()
                            Text(viewModel.formatCurrencyDetailed(entry.amount))
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(itemColor)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
            }
        }
        .background(.regularMaterial)
        .cornerRadius(12)
    }

    private var itemColor: Color {
        switch item.type {
        case .income: return .green
        case .outcome: return .red
        case .savings: return .blue
        }
    }
}

// MARK: - Child Plan Card

struct ChildPlanCard: View {
    let childPlan: PlanEntity
    let viewModel: ParentPlanViewModel
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.formatMonthYear(childPlan.startDate))
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(viewModel.formatCurrency(childPlan.remainingAmount))
                    .font(.title3.bold())
                    .foregroundStyle(statusColor)

                HStack {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 6, height: 6)
                    Text(statusText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .frame(width: 140)
            .background(.background)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(statusColor.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var statusColor: Color {
        viewModel.getChildPlanStatus(childPlan).color
    }

    private var statusText: String {
        viewModel.getChildPlanStatus(childPlan).text
    }
}

// MARK: - Rounded Corners Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        if let plan = PersistenceController.preview.container.viewContext.registeredObjects.first(where: { $0 is PlanEntity }) as? PlanEntity {
            ParentPlanDetailView(parentPlan: plan)
        }
    }
}
