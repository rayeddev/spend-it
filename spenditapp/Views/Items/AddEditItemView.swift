//
//  AddEditItemView.swift
//  spenditapp
//
//  Created by RAYED AL NOOM on 2025-12-19.
//

import SwiftUI
internal import CoreData

// MARK: - Add/Edit Item View

struct AddEditItemView: View {

    // MARK: - Properties

    @ObservedObject var plan: PlanEntity
    let itemType: ItemType
    let editingItem: PlanItemEntity?

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var amount: Decimal = 0
    @State private var icon = ""
    @State private var notes = ""
    @State private var showingCalculator = false
    @State private var showingError = false
    @State private var errorMessage = ""

    // Common icons by type
    private let incomeIcons = ["dollarsign.circle", "creditcard", "banknote", "briefcase", "chart.line.uptrend.xyaxis"]
    private let outcomeIcons = ["house", "cart", "car", "fork.knife", "film", "gamecontroller", "tshirt", "heart.text.square"]
    private let savingsIcons = ["banknote", "chart.pie", "arrow.down.circle", "shield", "star"]

    // MARK: - Initialization

    init(plan: PlanEntity, itemType: ItemType, editingItem: PlanItemEntity? = nil) {
        self.plan = plan
        self.itemType = itemType
        self.editingItem = editingItem

        if let item = editingItem {
            // Editing existing item
            _name = State(initialValue: item.name ?? "")
            _amount = State(initialValue: item.amountDecimal ?? 0)
            _icon = State(initialValue: item.icon ?? "")
            _notes = State(initialValue: item.notes ?? "")
        } else {
            // New item - set default icon based on type
            let defaultIcon: String
            switch itemType {
            case .income:
                defaultIcon = "dollarsign.circle"
            case .outcome:
                defaultIcon = "house"
            case .savings:
                defaultIcon = "banknote"
            }
            _icon = State(initialValue: defaultIcon)
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $name)
                        .accessibilityLabel("Item name")

                    Button {
                        showingCalculator = true
                    } label: {
                        HStack {
                            Text("Amount")
                                .foregroundStyle(.primary)

                            Spacer()

                            Text(CurrencyFormatter.shared.string(from: amount, currencyCode: plan.currencyCode ?? "USD"))
                                .foregroundStyle(.blue)
                                .font(.system(.body, design: .rounded).weight(.semibold))
                        }
                    }
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                        ForEach(iconOptions, id: \.self) { iconName in
                            Button {
                                icon = iconName
                                HapticManager.shared.selection()
                            } label: {
                                Image(systemName: iconName)
                                    .font(.title2)
                                    .foregroundStyle(icon == iconName ? typeColor : .secondary)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle()
                                            .fill(icon == iconName ? typeColor.opacity(0.2) : Color.clear)
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Notes")
                }

                if editingItem != nil {
                    Section {
                        Button(role: .destructive) {
                            deleteItem()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Item")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(editingItem == nil ? "Add \(itemType.displayName)" : "Edit \(itemType.displayName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(editingItem == nil ? "Add" : "Save") {
                        saveItem()
                    }
                    .disabled(!isValid)
                }
            }
            .sheet(isPresented: $showingCalculator) {
                CalculatorView(currencyCode: plan.currencyCode ?? "USD", initialValue: amount) { value in
                    amount = value
                }
                .presentationDetents([.medium])
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Computed Properties

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && amount >= 0
    }

    private var iconOptions: [String] {
        switch itemType {
        case .income: return incomeIcons
        case .outcome: return outcomeIcons
        case .savings: return savingsIcons
        }
    }

    private var typeColor: Color {
        switch itemType {
        case .income: return .green
        case .outcome: return .red
        case .savings: return .blue
        }
    }

    // MARK: - Actions

    private func saveItem() {
        if let existing = editingItem {
            // Update existing
            existing.name = name
            existing.amountDecimal = amount
            existing.icon = icon.isEmpty ? nil : icon
            existing.notes = notes.isEmpty ? nil : notes
            existing.updatedAt = Date()
        } else {
            // Create new
            let item = PlanItemEntity.create(
                in: viewContext,
                plan: plan,
                name: name,
                amount: amount,
                type: itemType
            )
            item.icon = icon.isEmpty ? nil : icon
            item.notes = notes.isEmpty ? nil : notes

            // Activate plan if it's in draft
            if plan.statusEnum == .draft {
                plan.statusEnum = .active
                plan.updatedAt = Date()
            }
        }

        do {
            try viewContext.save()
            HapticManager.shared.success()
            dismiss()
        } catch {
            errorMessage = "Failed to save item: \(error.localizedDescription)"
            showingError = true
            HapticManager.shared.error()
        }
    }

    private func deleteItem() {
        guard let item = editingItem else { return }

        HapticManager.shared.warning()
        viewContext.delete(item)

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error deleting item: \(error)")
        }
    }
}

// MARK: - Preview

#Preview {
    AddEditItemView(
        plan: {
            let context = PersistenceController.preview.container.viewContext
            return context.registeredObjects
                .compactMap { $0 as? PlanEntity }
                .first!
        }(),
        itemType: .outcome
    )
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
