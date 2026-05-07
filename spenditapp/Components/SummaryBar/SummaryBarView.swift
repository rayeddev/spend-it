//
//  SummaryBarView.swift
//  spenditapp
//
//  Created by RAYED AL NOOM on 2025-12-19.
//

import SwiftUI
internal import CoreData

// MARK: - Summary Bar View

struct SummaryBarView: View {

    // MARK: - Properties

    @ObservedObject var plan: PlanEntity
    let onConvertToSavings: () -> Void

    @State private var showingDetails = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: 14) {
            // Summary row with improved spacing
            HStack(spacing: 12) {
                SummaryColumn(
                    label: "Income",
                    value: plan.totalIncome,
                    color: .green,
                    gradient: GradientStyles.incomeGradient,
                    currencyCode: plan.currencyCode ?? "USD"
                )

                Divider()
                    .frame(height: 50)

                SummaryColumn(
                    label: "Expenses",
                    value: plan.totalOutcome,
                    color: .red,
                    gradient: GradientStyles.expenseGradient,
                    currencyCode: plan.currencyCode ?? "USD"
                )

                Divider()
                    .frame(height: 50)

                SummaryColumn(
                    label: "Savings",
                    value: plan.totalSavings,
                    color: .blue,
                    gradient: GradientStyles.savingsGradient,
                    currencyCode: plan.currencyCode ?? "USD"
                )
            }
            .frame(height: 70)

            // Remaining amount with enhanced styling
            VStack(spacing: 6) {
                Text("REMAINING")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .tracking(1.2)

                Text(formattedRemaining)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(remainingGradient)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: plan.remainingAmount)
                    .accessibilityLabel("Remaining amount: \(formattedRemaining)")
            }
            .padding(.vertical, 4)

            // Convert button with modern styling
            if plan.remainingAmount > 0 {
                Button {
                    onConvertToSavings()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.body.weight(.semibold))
                        Text("Convert to Savings")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(GradientStyles.savingsGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, y: 4)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(20)
        .glassMorphism(tint: .blue, intensity: 0.8)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .shadow(color: .black.opacity(0.12), radius: 24, y: 8)
    }

    // MARK: - Computed Properties

    private var formattedRemaining: String {
        CurrencyFormatter.shared.string(
            from: plan.remainingAmount,
            currencyCode: plan.currencyCode ?? "USD"
        )
    }

    private var remainingColor: Color {
        if plan.remainingAmount < 0 {
            return .red
        } else if plan.remainingAmount < (plan.totalIncome * 0.05) {
            return .orange
        } else {
            return .green
        }
    }

    private var remainingGradient: LinearGradient {
        if plan.remainingAmount < 0 {
            return GradientStyles.expenseGradient
        } else if plan.remainingAmount < (plan.totalIncome * 0.05) {
            return LinearGradient(
                colors: [Color.orange, Color.red],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return GradientStyles.incomeGradient
        }
    }
}

// MARK: - Summary Column

struct SummaryColumn: View {

    let label: String
    let value: Decimal
    let color: Color
    let gradient: LinearGradient
    let currencyCode: String

    var body: some View {
        VStack(spacing: 6) {
            Text(label.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .tracking(1.0)

            Text(CurrencyFormatter.shared.abbreviatedString(from: value, currencyCode: currencyCode))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(gradient)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.25), value: value)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Spacer()
        SummaryBarView(
            plan: {
                let plan = PersistenceController.preview.container.viewContext.registeredObjects
                    .compactMap { $0 as? PlanEntity }
                    .first!
                return plan
            }()
        ) {
            print("Convert to savings")
        }
    }
    .background(Color(.systemGroupedBackground))
}
