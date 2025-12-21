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
        ZStack(alignment: .bottomTrailing) {
            // Gradient background
            AdaptiveGradientView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Summary card at top
                SummaryBarView(plan: plan) {
                    convertRemainingToSavings()
                }
                .padding(.top, 8)

                // Custom tab picker with modern styling
                CustomTabPicker(selection: $selectedTab)

                // Items list - takes all remaining space
                ItemsListView(
                    items: plan.items(ofType: selectedTab),
                    plan: plan,
                    onEdit: { item in
                        editingItem = item
                    }
                )
            }

            // Floating Action Button at bottom right
            Button {
                showingAddItem = true
                HapticManager.shared.lightImpact()
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(fabGradient)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
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

    // MARK: - Computed Properties

    private var fabGradient: LinearGradient {
        switch selectedTab {
        case .income:
            return GradientStyles.incomeGradient
        case .outcome:
            return GradientStyles.expenseGradient
        case .savings:
            return GradientStyles.savingsGradient
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
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
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
        .background(Color.clear)
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
        HStack(spacing: 14) {
            // Icon with gradient background
            ZStack {
                Circle()
                    .fill(item.isFrozen ? frozenIconGradient : iconGradient)
                    .frame(width: 44, height: 44)
                    .overlay {
                        if item.isFrozen {
                            Circle()
                                .strokeBorder(Color.cyan.opacity(0.3), lineWidth: 2)
                        }
                    }

                if let icon = item.icon {
                    Image(systemName: icon)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                }

                // Frozen overlay icon
                if item.isFrozen {
                    Image(systemName: "snowflake")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.cyan)
                        .background(
                            Circle()
                                .fill(.white)
                                .frame(width: 16, height: 16)
                        )
                        .offset(x: 16, y: -16)
                }
            }

            // Name
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(item.name ?? "Unnamed")
                        .font(.body.weight(.medium))
                        .foregroundStyle(item.isFrozen ? .secondary : .primary)

                    if item.isFrozen {
                        Image(systemName: "pause.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.cyan.opacity(0.7))
                    }
                }

                if item.isFrozen {
                    Text("Paused from calculations")
                        .font(.caption2)
                        .foregroundStyle(.cyan.opacity(0.8))
                }
            }

            Spacer()

            // Amount
            Text(amountText)
                .font(.system(.body, design: .rounded).weight(.semibold))
                .foregroundStyle(amountColor)
        }
        .itemCard()
        .overlay {
            if item.isFrozen {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.cyan.opacity(0.3), Color.blue.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
        }
        .overlay {
            if item.isFrozen {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.cyan.opacity(0.05))
            }
        }
        .saturation(item.isFrozen ? 0.5 : 1.0)
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

    private var iconGradient: LinearGradient {
        switch item.typeEnum {
        case .income: return GradientStyles.incomeGradient
        case .outcome: return GradientStyles.expenseGradient
        case .savings: return GradientStyles.savingsGradient
        }
    }

    private var frozenIconGradient: LinearGradient {
        LinearGradient(
            colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.4)],
            startPoint: .leading,
            endPoint: .trailing
        )
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
