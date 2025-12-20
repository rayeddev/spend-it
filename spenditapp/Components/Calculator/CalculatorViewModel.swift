//
//  CalculatorViewModel.swift
//  spenditapp
//
//  Created by RAYED AL NOOM on 2025-12-19.
//

import Foundation
import Combine

// MARK: - Calculator View Model

@Observable
class CalculatorViewModel {

    // MARK: - Properties

    var displayText: String = "0"
    var currentValue: Decimal = 0

    private var firstOperand: Decimal?
    private var currentOperation: Operation?
    private var shouldResetDisplay = false

    private let maxValue = Decimal(999_999_999.99)
    private let minValue = Decimal(0)

    // MARK: - Operations

    enum Operation: String {
        case add = "+"
        case subtract = "−"
        case multiply = "×"
        case divide = "÷"

        func calculate(_ lhs: Decimal, _ rhs: Decimal) -> Decimal {
            switch self {
            case .add: return lhs + rhs
            case .subtract: return lhs - rhs
            case .multiply: return lhs * rhs
            case .divide: return rhs != 0 ? lhs / rhs : 0
            }
        }
    }

    // MARK: - Input Handling

    func inputDigit(_ digit: Int) {
        HapticManager.shared.lightImpact()

        if shouldResetDisplay {
            displayText = "\(digit)"
            shouldResetDisplay = false
            return
        }

        if displayText == "0" {
            displayText = "\(digit)"
        } else {
            displayText += "\(digit)"
        }

        updateCurrentValue()
    }

    func inputDecimal() {
        HapticManager.shared.lightImpact()

        if shouldResetDisplay {
            displayText = "0."
            shouldResetDisplay = false
            return
        }

        if !displayText.contains(".") {
            displayText += "."
        }
    }

    func inputOperation(_ operation: Operation) {
        HapticManager.shared.lightImpact()

        if let firstOp = firstOperand, let currentOp = currentOperation {
            let result = currentOp.calculate(firstOp, currentValue)
            currentValue = min(max(result, minValue), maxValue)
            displayText = formatDecimal(currentValue)
        }

        firstOperand = currentValue
        currentOperation = operation
        shouldResetDisplay = true
    }

    func calculate() {
        HapticManager.shared.mediumImpact()

        guard let firstOp = firstOperand, let operation = currentOperation else {
            return
        }

        let result = operation.calculate(firstOp, currentValue)
        currentValue = min(max(result, minValue), maxValue)
        displayText = formatDecimal(currentValue)

        firstOperand = nil
        currentOperation = nil
        shouldResetDisplay = true
    }

    func clear() {
        HapticManager.shared.lightImpact()

        displayText = "0"
        currentValue = 0
        firstOperand = nil
        currentOperation = nil
        shouldResetDisplay = false
    }

    func backspace() {
        HapticManager.shared.lightImpact()

        if displayText.count > 1 {
            displayText.removeLast()
        } else {
            displayText = "0"
        }

        updateCurrentValue()
    }

    // MARK: - Value Management

    func setValue(_ value: Decimal) {
        currentValue = min(max(value, minValue), maxValue)
        displayText = formatDecimal(currentValue)
        shouldResetDisplay = false
    }

    func getValue() -> Decimal {
        return currentValue
    }

    // MARK: - Private Helpers

    private func updateCurrentValue() {
        if let decimal = Decimal(string: displayText) {
            currentValue = min(max(decimal, minValue), maxValue)
        }
    }

    private func formatDecimal(_ decimal: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSDecimalNumber(decimal: decimal)) ?? "0"
    }
}
