//
//  CreateGroupPlanView.swift
//  spenditapp
//
//  Created by Group Planning Feature
//

import SwiftUI
internal import CoreData

// MARK: - Create Group Plan View

struct CreateGroupPlanView: View {

    // MARK: - Properties

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = GroupPlanViewModel()
    @State private var showingItemEditor = false
    @State private var editingItem: GroupPlanItem?
    @State private var editingItemType: ItemType = .income
    @State private var createdPlan: PlanEntity?
    @State private var navigateToParent = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                // Plan Details
                planDetailsSection

                // Group Type
                groupTypeSection

                // Items Sections
                incomeSection
                outcomeSection
                savingsSection

                // Summary
                summarySection

                // Preview
                childPlansPreviewSection
            }
            .navigationTitle("New Group Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task {
                            await createGroupPlan()
                        }
                    }
                    .disabled(!viewModel.isValid || viewModel.isCreating)
                }
            }
            .sheet(isPresented: $showingItemEditor) {
                itemEditorSheet
            }
            .alert("Error", isPresented: $viewModel.showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
            .disabled(viewModel.isCreating)
            .overlay {
                if viewModel.isCreating {
                    ProgressView("Creating group plan...")
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(12)
                }
            }
            .navigationDestination(isPresented: $navigateToParent) {
                if let plan = createdPlan {
                    ParentPlanDetailView(parentPlan: plan)
                }
            }
        }
    }

    // MARK: - Plan Details Section

    private var planDetailsSection: some View {
        Section {
            TextField("Plan Name", text: $viewModel.planName)
                .accessibilityLabel("Plan name")

            DatePicker("Start Date", selection: $viewModel.startDate, displayedComponents: .date)
        } header: {
            Text("Plan Details")
        } footer: {
            Text("Group plan will span one year starting from this date")
        }
    }

    // MARK: - Group Type Section

    private var groupTypeSection: some View {
        Section {
            Picker("Group Type", selection: $viewModel.groupType) {
                ForEach(GroupType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
        } header: {
            Text("Group Type")
        } footer: {
            Text("\(viewModel.groupType.displayName) will create \(viewModel.childPlanCount) child plans")
        }
    }

    // MARK: - Income Section

    private var incomeSection: some View {
        Section {
            ForEach(viewModel.incomeItems) { item in
                ItemRow(item: item, viewModel: viewModel) {
                    editingItem = item
                    editingItemType = .income
                    showingItemEditor = true
                }
            }
            .onDelete { offsets in
                viewModel.deleteItems(ofType: .income, at: offsets)
            }

            Button(action: {
                viewModel.addIncomeItem()
                if let lastItem = viewModel.incomeItems.last {
                    editingItem = lastItem
                    editingItemType = .income
                    showingItemEditor = true
                }
            }) {
                Label("Add Income", systemImage: "plus.circle.fill")
                    .foregroundStyle(.green)
            }
        } header: {
            HStack {
                Text("Income")
                Spacer()
                Text(formatCurrency(viewModel.totalIncome))
                    .foregroundStyle(.green)
            }
        } footer: {
            Text("Total annual income. Each child plan will receive \(formatCurrency(viewModel.getDividedAmount(for: viewModel.totalIncome))) per period.")
        }
    }

    // MARK: - Outcome Section

    private var outcomeSection: some View {
        Section {
            ForEach(viewModel.outcomeItems) { item in
                ItemRow(item: item, viewModel: viewModel) {
                    editingItem = item
                    editingItemType = .outcome
                    showingItemEditor = true
                }
            }
            .onDelete { offsets in
                viewModel.deleteItems(ofType: .outcome, at: offsets)
            }

            Button(action: {
                viewModel.addOutcomeItem()
                if let lastItem = viewModel.outcomeItems.last {
                    editingItem = lastItem
                    editingItemType = .outcome
                    showingItemEditor = true
                }
            }) {
                Label("Add Expense", systemImage: "plus.circle.fill")
                    .foregroundStyle(.red)
            }
        } header: {
            HStack {
                Text("Expenses")
                Spacer()
                Text(formatCurrency(viewModel.totalOutcome))
                    .foregroundStyle(.red)
            }
        } footer: {
            Text("Total annual expenses. Each child plan will have \(formatCurrency(viewModel.getDividedAmount(for: viewModel.totalOutcome))) per period.")
        }
    }

    // MARK: - Savings Section

    private var savingsSection: some View {
        Section {
            ForEach(viewModel.savingsItems) { item in
                ItemRow(item: item, viewModel: viewModel) {
                    editingItem = item
                    editingItemType = .savings
                    showingItemEditor = true
                }
            }
            .onDelete { offsets in
                viewModel.deleteItems(ofType: .savings, at: offsets)
            }

            Button(action: {
                viewModel.addSavingsItem()
                if let lastItem = viewModel.savingsItems.last {
                    editingItem = lastItem
                    editingItemType = .savings
                    showingItemEditor = true
                }
            }) {
                Label("Add Savings", systemImage: "plus.circle.fill")
                    .foregroundStyle(.blue)
            }
        } header: {
            HStack {
                Text("Savings")
                Spacer()
                Text(formatCurrency(viewModel.totalSavings))
                    .foregroundStyle(.blue)
            }
        } footer: {
            Text("Total annual savings. Each child plan will save \(formatCurrency(viewModel.getDividedAmount(for: viewModel.totalSavings))) per period.")
        }
    }

    // MARK: - Summary Section

    private var summarySection: some View {
        Section {
            HStack {
                Text("Total Income")
                Spacer()
                Text(formatCurrency(viewModel.totalIncome))
                    .foregroundStyle(.green)
            }

            HStack {
                Text("Total Expenses")
                Spacer()
                Text(formatCurrency(viewModel.totalOutcome))
                    .foregroundStyle(.red)
            }

            HStack {
                Text("Total Savings")
                Spacer()
                Text(formatCurrency(viewModel.totalSavings))
                    .foregroundStyle(.blue)
            }

            Divider()

            HStack {
                Text("Remaining")
                    .fontWeight(.bold)
                Spacer()
                Text(formatCurrency(viewModel.totalRemaining))
                    .fontWeight(.bold)
                    .foregroundStyle(viewModel.isBalanced ? .green : .red)
            }
        } header: {
            Text("Annual Summary")
        } footer: {
            if !viewModel.isBalanced {
                Text("⚠️ Your plan has a deficit of \(formatCurrency(abs(viewModel.totalRemaining)))")
                    .foregroundStyle(.red)
            }
        }
    }

    // MARK: - Child Plans Preview Section

    private var childPlansPreviewSection: some View {
        Section {
            ForEach(0..<min(3, viewModel.childPlanCount), id: \.self) { index in
                if let preview = viewModel.getChildPlanPreview(for: index) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(preview.name)
                            .font(.headline)
                        Text("\(formatDate(preview.startDate)) - \(formatDate(preview.endDate))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if viewModel.childPlanCount > 3 {
                Text("+ \(viewModel.childPlanCount - 3) more child plans")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        } header: {
            Text("Child Plans Preview")
        } footer: {
            Text("\(viewModel.childPlanCount) child plans will be created automatically")
        }
    }

    // MARK: - Item Editor Sheet

    private var itemEditorSheet: some View {
        ItemEditorView(
            item: editingItem,
            type: editingItemType,
            viewModel: viewModel
        ) {
            showingItemEditor = false
            editingItem = nil
        }
    }

    // MARK: - Actions

    private func createGroupPlan() async {
        do {
            let plan = try await viewModel.createGroup(in: viewContext)
            HapticManager.shared.success()
            createdPlan = plan
            navigateToParent = true
        } catch {
            HapticManager.shared.error()
        }
    }

    // MARK: - Helpers

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = viewModel.currencyCode
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Item Row

struct ItemRow: View {
    let item: GroupPlanItem
    let viewModel: GroupPlanViewModel
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name.isEmpty ? "Unnamed" : item.name)
                        .foregroundStyle(item.name.isEmpty ? .secondary : .primary)

                    Text("Per period: \(formatDividedAmount(item.amount))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(formatCurrency(item.amount))
                    .fontWeight(.semibold)
                    .foregroundStyle(item.type.systemColor == "green" ? .green :
                                     item.type.systemColor == "red" ? .red : .blue)
            }
        }
        .buttonStyle(.plain)
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = viewModel.currencyCode
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0"
    }

    private func formatDividedAmount(_ amount: Decimal) -> String {
        let divided = viewModel.getDividedAmount(for: amount)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = viewModel.currencyCode
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSDecimalNumber(decimal: divided)) ?? "$0.00"
    }
}

// MARK: - Item Editor View

struct ItemEditorView: View {
    let item: GroupPlanItem?
    let type: ItemType
    @Bindable var viewModel: GroupPlanViewModel

    let onDismiss: () -> Void

    @State private var name: String
    @State private var amount: Decimal
    @State private var showingCalculator = false

    init(item: GroupPlanItem?, type: ItemType, viewModel: GroupPlanViewModel, onDismiss: @escaping () -> Void) {
        self.item = item
        self.type = type
        self.viewModel = viewModel
        self.onDismiss = onDismiss

        _name = State(initialValue: item?.name ?? "")
        _amount = State(initialValue: item?.amount ?? 0)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Item Name", text: $name)
                } header: {
                    Text("Details")
                }

                Section {
                    Button(action: {
                        showingCalculator = true
                    }) {
                        HStack {
                            Text("Annual Amount")
                            Spacer()
                            Text(formatCurrency(amount))
                                .foregroundStyle(type.systemColor == "green" ? .green :
                                                 type.systemColor == "red" ? .red : .blue)
                        }
                    }
                } header: {
                    Text("Amount")
                } footer: {
                    Text("Per period: \(formatDividedAmount(amount))")
                }
            }
            .navigationTitle(item == nil ? "New Item" : "Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveItem()
                        onDismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(isPresented: $showingCalculator) {
                CalculatorView(currencyCode: viewModel.currencyCode, initialValue: amount) { value in
                    amount = value
                }
                .presentationDetents([.medium])
            }
        }
    }

    private func saveItem() {
        if let existingItem = item {
            viewModel.updateItem(existingItem, name: name, amount: amount)
        }
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = viewModel.currencyCode
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? "$0"
    }

    private func formatDividedAmount(_ value: Decimal) -> String {
        let divided = viewModel.getDividedAmount(for: value)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = viewModel.currencyCode
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSDecimalNumber(decimal: divided)) ?? "$0.00"
    }
}

// MARK: - Preview

#Preview {
    CreateGroupPlanView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
