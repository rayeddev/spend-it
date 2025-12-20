//
//  PlanDetailView.swift
//  spenditapp
//
//  Created by RAYED AL NOOM on 2025-12-19.
//

import SwiftUI
internal import CoreData

// MARK: - Plan Detail View

struct PlanDetailView: View {

    // MARK: - Properties

    @ObservedObject var plan: PlanEntity

    @Environment(\.managedObjectContext) private var viewContext

    @State private var selectedTab: ItemType = .outcome
    @State private var showingAddItem = false
    @State private var showingClonePlan = false
    @State private var editingItem: PlanItemEntity?

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Tab picker
                Picker("Type", selection: $selectedTab) {
                    Text("Expenses").tag(ItemType.outcome)
                    Text("Income").tag(ItemType.income)
                    Text("Savings").tag(ItemType.savings)
                }
                .pickerStyle(.segmented)
                .padding()

                // Items list - takes all remaining space
                ItemsListView(
                    items: plan.items(ofType: selectedTab),
                    plan: plan,
                    onEdit: { item in
                        editingItem = item
                    }
                )
            }

            // Summary bar pinned at bottom
            VStack {
                Spacer()
                SummaryBarView(plan: plan) {
                    convertRemainingToSavings()
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .navigationTitle(plan.name ?? "Plan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingAddItem = true
                    } label: {
                        Label("Add Item", systemImage: "plus")
                    }

                    Button {
                        showingClonePlan = true
                    } label: {
                        Label("Clone Plan", systemImage: "doc.on.doc")
                    }

                    Divider()

                    Button(role: .destructive) {
                        deletePlan()
                    } label: {
                        Label("Delete Plan", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddEditItemView(plan: plan, itemType: selectedTab)
        }
        .sheet(item: $editingItem) { item in
            AddEditItemView(plan: plan, itemType: item.typeEnum, editingItem: item)
        }
        .sheet(isPresented: $showingClonePlan) {
            ClonePlanView(sourcePlan: plan)
        }
    }

    // MARK: - Actions

    private func convertRemainingToSavings() {
        guard plan.remainingAmount > 0 else { return }

        let savingsItem = PlanItemEntity.create(
            in: viewContext,
            plan: plan,
            name: "Extra Savings",
            amount: plan.remainingAmount,
            type: .savings
        )

        savingsItem.icon = "arrow.down.circle.fill"

        do {
            try viewContext.save()
            HapticManager.shared.success()

            // Switch to savings tab to show new item
            withAnimation {
                selectedTab = .savings
            }
        } catch {
            print("Error converting to savings: \(error)")
            HapticManager.shared.error()
        }
    }

    private func deletePlan() {
        HapticManager.shared.warning()

        viewContext.delete(plan)

        do {
            try viewContext.save()
        } catch {
            print("Error deleting plan: \(error)")
        }
    }
}

// MARK: - Items List View

struct ItemsListView: View {

    let items: [PlanItemEntity]
    @ObservedObject var plan: PlanEntity
    let onEdit: (PlanItemEntity) -> Void

    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        if items.isEmpty {
            emptyState
        } else {
            List {
                ForEach(items) { item in
                    PlanItemRowView(item: item, plan: plan, onEdit: onEdit)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                .onDelete { indexSet in
                    deleteItems(at: indexSet)
                }
                .onMove { from, to in
                    moveItems(from: from, to: to)
                }

                // Bottom spacer to prevent content from being hidden by SummaryBar
                Color.clear
                    .frame(height: 200)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: itemIcon)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No \(itemTypeText) Yet")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Tap '+' to add your first \(itemTypeText.lowercased())")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private var itemIcon: String {
        guard let firstItem = items.first else { return "dollarsign.circle" }
        switch firstItem.typeEnum {
        case .income: return "dollarsign.circle"
        case .outcome: return "cart"
        case .savings: return "banknote"
        }
    }

    private var itemTypeText: String {
        guard let firstItem = items.first else { return "Items" }
        return firstItem.typeEnum.displayName + "s"
    }

    private func deleteItems(at indexSet: IndexSet) {
        HapticManager.shared.warning()

        withAnimation {
            indexSet.forEach { index in
                viewContext.delete(items[index])
            }

            do {
                try viewContext.save()
                HapticManager.shared.success()
            } catch {
                print("Error deleting item: \(error)")
            }
        }
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        var revisedItems = items
        revisedItems.move(fromOffsets: source, toOffset: destination)

        // Update sort orders
        for (index, item) in revisedItems.enumerated() {
            item.sortOrder = Int16(index)
            item.updatedAt = Date()
        }

        do {
            try viewContext.save()
            HapticManager.shared.lightImpact()
        } catch {
            print("Error reordering items: \(error)")
        }
    }
}

// MARK: - Plan Item Row View

struct PlanItemRowView: View {

    @ObservedObject var item: PlanItemEntity
    @ObservedObject var plan: PlanEntity
    let onEdit: (PlanItemEntity) -> Void

    @Environment(\.managedObjectContext) private var viewContext
    @State private var offset: CGFloat = 0

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            if let icon = item.icon {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(item.typeEnum.systemColor == "green" ? .green :
                                   item.typeEnum.systemColor == "red" ? .red : .blue)
                    .frame(width: 32)
            }

            // Name
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name ?? "Unnamed")
                    .font(.body)

                if item.isFrozen {
                    HStack(spacing: 4) {
                        Image(systemName: "snowflake")
                            .font(.caption2)
                        Text("Frozen")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Amount
            Text(amountText)
                .font(.system(.body, design: .rounded).weight(.semibold))
                .foregroundStyle(amountColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(item.isFrozen ? Color(.systemGray6) : Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(item.isFrozen ? Color(.systemGray4) : Color.clear, lineWidth: 1)
        )
        .opacity(item.isFrozen ? 0.7 : 1.0)
        .offset(x: offset)
        .animation(nil, value: offset)  // Disable implicit animations for offset changes
        .gesture(
            DragGesture(minimumDistance: 20)
                .onChanged { gesture in
                    // Only respond to horizontal swipes (not vertical scrolling)
                    let horizontalAmount = abs(gesture.translation.width)
                    let verticalAmount = abs(gesture.translation.height)

                    // If the gesture is more horizontal than vertical, handle it
                    if horizontalAmount > verticalAmount {
                        // Only allow right swipe - update immediately without animation
                        if gesture.translation.width > 0 {
                            offset = min(gesture.translation.width, 100)
                        }
                    }
                }
                .onEnded { gesture in
                    let horizontalAmount = abs(gesture.translation.width)
                    let verticalAmount = abs(gesture.translation.height)

                    // Only toggle freeze if it was a horizontal swipe
                    if horizontalAmount > verticalAmount && gesture.translation.width > 50 {
                        // Swipe threshold reached - toggle freeze
                        toggleFrozen()
                    }
                    // Reset offset with explicit animation
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        offset = 0
                    }
                }
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit(item)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.name ?? "Unnamed"), \(item.formattedAmount(currencyCode: plan.currencyCode ?? "USD")), \(item.isFrozen ? "frozen" : "active")")
        .accessibilityHint("Swipe right to \(item.isFrozen ? "unfreeze" : "freeze") this item")
    }

    private var typeColor: Color {
        switch item.typeEnum {
        case .income: return .green
        case .outcome: return .red
        case .savings: return .blue
        }
    }

    private var amountText: String {
        // For outcome items, show plain number without currency symbol
        if item.typeEnum == .outcome {
            return CurrencyFormatter.shared.plainString(
                from: item.amountDecimal ?? 0,
                currencyCode: plan.currencyCode ?? "USD"
            )
        } else {
            // For income and savings, keep currency symbol
            return item.formattedAmount(currencyCode: plan.currencyCode ?? "USD")
        }
    }

    private var amountColor: Color {
        // Frozen items always show secondary color
        if item.isFrozen {
            return .secondary
        }

        // Outcome items show light gray (secondary) color
        if item.typeEnum == .outcome {
            return .secondary
        }

        // Other items show primary color
        return .primary
    }

    private func toggleFrozen() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            item.isFrozen.toggle()
            item.updatedAt = Date()

            // Update plan's updatedAt to trigger recalculation
            plan.updatedAt = Date()
        }

        do {
            try viewContext.save()
            HapticManager.shared.lightImpact()
        } catch {
            print("Error toggling frozen: \(error)")
            HapticManager.shared.error()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PlanDetailView(plan: {
            let context = PersistenceController.preview.container.viewContext
            let plan = context.registeredObjects
                .compactMap { $0 as? PlanEntity }
                .first!
            return plan
        }())
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
