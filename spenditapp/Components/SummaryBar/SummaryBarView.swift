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
        VStack(spacing: 12) {
            // Summary row
            HStack(spacing: 16) {
                SummaryColumn(
                    label: "Income",
                    value: plan.totalIncome,
                    color: .green,
                    currencyCode: plan.currencyCode ?? "USD"
                )

                Divider()

                SummaryColumn(
                    label: "Outcome",
                    value: plan.totalOutcome,
                    color: .red,
                    currencyCode: plan.currencyCode ?? "USD"
                )

                Divider()

                SummaryColumn(
                    label: "Savings",
                    value: plan.totalSavings,
                    color: .blue,
                    currencyCode: plan.currencyCode ?? "USD"
                )
            }
            .frame(height: 60)

            // Remaining amount
            VStack(spacing: 4) {
                Text("REMAINING")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(formattedRemaining)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(remainingColor)
                    .animation(.easeInOut(duration: 0.3), value: plan.remainingAmount)
                    .accessibilityLabel("Remaining amount: \(formattedRemaining)")
            }

            // Convert to Savings button
            if plan.remainingAmount > 0 {
                Button {
                    onConvertToSavings()
                } label: {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                        Text("Convert to Savings")
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
        )
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
}

// MARK: - Summary Column

struct SummaryColumn: View {

    let label: String
    let value: Decimal
    let color: Color
    let currencyCode: String

    var body: some View {
        VStack(spacing: 4) {
            Text(label.uppercased())
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text(CurrencyFormatter.shared.abbreviatedString(from: value, currencyCode: currencyCode))
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(color)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
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
