//
//  NewPlanView.swift
//  spenditapp
//
//  Created by RAYED AL NOOM on 2025-12-19.
//

import SwiftUI
internal import CoreData

// MARK: - New Plan View

struct NewPlanView: View {

    // MARK: - Properties

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var planName = ""
    @State private var startDate = Date()
    @State private var endDate: Date
    @State private var isRecurring = false
    @State private var recurrenceType: RecurrenceType = .monthly
    @State private var showingError = false
    @State private var errorMessage = ""

    // MARK: - Initialization

    init() {
        let calendar = Calendar.current
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        _endDate = State(initialValue: nextMonth)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Plan Name", text: $planName)
                        .accessibilityLabel("Plan name")
                } header: {
                    Text("Plan Details")
                } footer: {
                    Text("Give your plan a descriptive name (e.g., 'December 2025 Budget')")
                }

                Section("Dates") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }

                Section {
                    Toggle("Recurring Plan", isOn: $isRecurring)

                    if isRecurring {
                        Picker("Repeat", selection: $recurrenceType) {
                            ForEach(RecurrenceType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                    }
                } footer: {
                    if isRecurring {
                        Text("This plan will repeat on the selected schedule")
                    }
                }
            }
            .navigationTitle("New Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createPlan()
                    }
                    .disabled(!isValid)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Validation

    private var isValid: Bool {
        !planName.trimmingCharacters(in: .whitespaces).isEmpty &&
        endDate > startDate
    }

    // MARK: - Actions

    private func createPlan() {
        let plan = PlanEntity.create(
            in: viewContext,
            name: planName,
            startDate: startDate,
            endDate: endDate
        )

        plan.isRecurring = isRecurring
        if isRecurring {
            plan.recurrenceTypeEnum = recurrenceType
        }

        plan.statusEnum = .draft

        do {
            try viewContext.save()
            HapticManager.shared.success()
            dismiss()
        } catch {
            errorMessage = "Failed to create plan: \(error.localizedDescription)"
            showingError = true
            HapticManager.shared.error()
        }
    }
}

// MARK: - Preview

#Preview {
    NewPlanView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
