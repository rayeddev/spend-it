//
//  ClonePlanView.swift
//  spenditapp
//
//  Created by RAYED AL NOOM on 2025-12-19.
//

import SwiftUI
internal import CoreData

// MARK: - Clone Plan View

struct ClonePlanView: View {

    // MARK: - Properties

    @ObservedObject var sourcePlan: PlanEntity

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var planName = ""
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var isCloning = false
    @State private var showingError = false
    @State private var errorMessage = ""

    // MARK: - Initialization

    init(sourcePlan: PlanEntity) {
        self.sourcePlan = sourcePlan

        // Calculate next period dates based on recurrence type
        let calendar = Calendar.current
        let sourceStart = sourcePlan.startDate ?? Date()
        let sourceEnd = sourcePlan.endDate ?? Date()

        let nextStart: Date
        let nextEnd: Date

        if let recurrence = sourcePlan.recurrenceTypeEnum {
            nextStart = recurrence.nextDate(from: sourceStart)
            let duration = calendar.dateComponents([.day], from: sourceStart, to: sourceEnd).day ?? 30
            nextEnd = calendar.date(byAdding: .day, value: duration, to: nextStart) ?? nextStart
        } else {
            nextStart = calendar.date(byAdding: .month, value: 1, to: sourceStart) ?? Date()
            nextEnd = calendar.date(byAdding: .month, value: 1, to: sourceEnd) ?? Date()
        }

        _startDate = State(initialValue: nextStart)
        _endDate = State(initialValue: nextEnd)

        // Generate new plan name
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        _planName = State(initialValue: dateFormatter.string(from: nextStart) + " Budget")
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Source Plan")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(sourcePlan.name ?? "Unnamed")
                    }

                    HStack {
                        Text("Items to Copy")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(sourcePlan.sortedItems.count)")
                    }
                }

                Section("New Plan") {
                    TextField("Plan Name", text: $planName)

                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }

                Section {
                    Text("All items will be copied with frozen state reset to active")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Clone Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isCloning)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Clone") {
                        clonePlan()
                    }
                    .disabled(!isValid || isCloning)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .overlay {
                if isCloning {
                    ZStack {
                        Color.black.opacity(0.2)
                            .ignoresSafeArea()

                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .scaleEffect(1.5)

                            Text("Cloning Plan...")
                                .font(.headline)
                        }
                        .padding(32)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                        )
                    }
                }
            }
        }
    }

    // MARK: - Validation

    private var isValid: Bool {
        !planName.trimmingCharacters(in: .whitespaces).isEmpty &&
        endDate > startDate
    }

    // MARK: - Actions

    private func clonePlan() {
        isCloning = true

        // Small delay to show progress indicator
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            performClone()
        }
    }

    private func performClone() {
        let newPlan = sourcePlan.clone(
            in: viewContext,
            name: planName,
            startDate: startDate,
            endDate: endDate
        )

        do {
            try viewContext.save()
            HapticManager.shared.success()

            // Small delay before dismissing to show success
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isCloning = false
                dismiss()
            }
        } catch {
            isCloning = false
            errorMessage = "Failed to clone plan: \(error.localizedDescription)"
            showingError = true
            HapticManager.shared.error()
        }
    }
}

// MARK: - Preview

#Preview {
    ClonePlanView(sourcePlan: {
        let context = PersistenceController.preview.container.viewContext
        return context.registeredObjects
            .compactMap { $0 as? PlanEntity }
            .first!
    }())
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
