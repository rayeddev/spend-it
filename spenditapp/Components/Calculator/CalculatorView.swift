//
//  CalculatorView.swift
//  spenditapp
//
//  Created by RAYED AL NOOM on 2025-12-19.
//

import SwiftUI

// MARK: - Calculator View

struct CalculatorView: View {

    // MARK: - Properties

    @State private var viewModel = CalculatorViewModel()
    let currencyCode: String
    let initialValue: Decimal?
    let onComplete: (Decimal) -> Void

    @Environment(\.dismiss) private var dismiss

    // MARK: - Initialization

    init(currencyCode: String = "USD",
         initialValue: Decimal? = nil,
         onComplete: @escaping (Decimal) -> Void) {
        self.currencyCode = currencyCode
        self.initialValue = initialValue
        self.onComplete = onComplete
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Display
            displayArea

            Divider()

            // Keypad
            keypad
        }
        .background(Color(.systemBackground))
        .onAppear {
            if let initial = initialValue {
                viewModel.setValue(initial)
            }
        }
    }

    // MARK: - Display Area

    private var displayArea: some View {
        VStack(alignment: .trailing, spacing: 8) {
            Text(CurrencyFormatter.shared.symbol(for: currencyCode))
                .font(.title2)
                .foregroundStyle(.secondary)

            Text(viewModel.displayText)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .accessibilityLabel("Amount: \(viewModel.displayText)")
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
        .frame(minHeight: 120)
    }

    // MARK: - Keypad

    private var keypad: some View {
        VStack(spacing: 12) {
            // Row 1: C, ⌫, ÷, ×
            HStack(spacing: 12) {
                CalculatorButton(title: "C", color: .orange) {
                    viewModel.clear()
                }
                CalculatorButton(title: "⌫", color: .orange) {
                    viewModel.backspace()
                }
                CalculatorButton(title: "÷", color: .blue) {
                    viewModel.inputOperation(.divide)
                }
                CalculatorButton(title: "×", color: .blue) {
                    viewModel.inputOperation(.multiply)
                }
            }

            // Row 2: 7, 8, 9, −
            HStack(spacing: 12) {
                CalculatorButton(title: "7") {
                    viewModel.inputDigit(7)
                }
                CalculatorButton(title: "8") {
                    viewModel.inputDigit(8)
                }
                CalculatorButton(title: "9") {
                    viewModel.inputDigit(9)
                }
                CalculatorButton(title: "−", color: .blue) {
                    viewModel.inputOperation(.subtract)
                }
            }

            // Row 3: 4, 5, 6, +
            HStack(spacing: 12) {
                CalculatorButton(title: "4") {
                    viewModel.inputDigit(4)
                }
                CalculatorButton(title: "5") {
                    viewModel.inputDigit(5)
                }
                CalculatorButton(title: "6") {
                    viewModel.inputDigit(6)
                }
                CalculatorButton(title: "+", color: .blue) {
                    viewModel.inputOperation(.add)
                }
            }

            // Row 4: 1, 2, 3, =
            HStack(spacing: 12) {
                CalculatorButton(title: "1") {
                    viewModel.inputDigit(1)
                }
                CalculatorButton(title: "2") {
                    viewModel.inputDigit(2)
                }
                CalculatorButton(title: "3") {
                    viewModel.inputDigit(3)
                }
                CalculatorButton(title: "=", color: .green) {
                    viewModel.calculate()
                }
            }

            // Row 5: 0 (wide), ., Done
            HStack(spacing: 12) {
                CalculatorButton(title: "0", wide: true) {
                    viewModel.inputDigit(0)
                }
                CalculatorButton(title: ".") {
                    viewModel.inputDecimal()
                }
                CalculatorButton(title: "Done", color: .green) {
                    HapticManager.shared.success()
                    onComplete(viewModel.getValue())
                    dismiss()
                }
            }
        }
        .padding(16)
    }
}

// MARK: - Calculator Button

struct CalculatorButton: View {

    let title: String
    var color: Color = .primary
    var wide: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(color == .primary ? .primary : Color.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(backgroundColor)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(maxWidth: wide ? .infinity : nil)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
    }

    private var backgroundColor: Color {
        switch color {
        case .orange:
            return Color.orange.opacity(0.2)
        case .blue:
            return Color.blue.opacity(0.2)
        case .green:
            return Color.green
        default:
            return Color(.systemGray5)
        }
    }
}

// MARK: - Preview

#Preview {
    CalculatorView(currencyCode: "USD", initialValue: 1500) { value in
        print("Value: \(value)")
    }
}
