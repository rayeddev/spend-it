//
//  CurrencyFormatter.swift
//  spenditapp
//
//  Created by RAYED AL NOOM on 2025-12-19.
//

import Foundation

// MARK: - Currency Formatter

/// Handles currency formatting throughout the app
class CurrencyFormatter {

    static let shared = CurrencyFormatter()

    private var formatters: [String: NumberFormatter] = [:]

    private init() {}

    // MARK: - Public Methods

    /// Format decimal as currency string
    func string(from decimal: Decimal, currencyCode: String = "USD") -> String {
        let formatter = getFormatter(for: currencyCode)
        return formatter.string(from: NSDecimalNumber(decimal: decimal)) ?? "$0.00"
    }

    /// Format decimal as abbreviated currency (e.g., $1.2K, $1.5M)
    func abbreviatedString(from decimal: Decimal, currencyCode: String = "USD") -> String {
        let number = NSDecimalNumber(decimal: decimal).doubleValue
        let absNumber = abs(number)

        let formatter = getFormatter(for: currencyCode)
        formatter.maximumFractionDigits = 1

        let abbreviation: String
        let divisor: Double

        if absNumber >= 1_000_000 {
            abbreviation = "M"
            divisor = 1_000_000
        } else if absNumber >= 1_000 {
            abbreviation = "K"
            divisor = 1_000
        } else {
            return string(from: decimal, currencyCode: currencyCode)
        }

        let abbreviated = number / divisor
        let result = formatter.string(from: NSNumber(value: abbreviated)) ?? "$0.0"
        return result + abbreviation
    }

    /// Parse string to decimal
    func decimal(from string: String, currencyCode: String = "USD") -> Decimal? {
        let formatter = getFormatter(for: currencyCode)
        let cleanedString = string.replacingOccurrences(of: "[^0-9.-]", with: "", options: .regularExpression)

        guard let number = formatter.number(from: cleanedString) else {
            return Decimal(string: cleanedString)
        }

        return number.decimalValue
    }

    /// Get currency symbol for code
    func symbol(for currencyCode: String) -> String {
        let locale = Locale(identifier: Locale.identifier(fromComponents: [NSLocale.Key.currencyCode.rawValue: currencyCode]))
        return locale.currencySymbol ?? "$"
    }

    // MARK: - Private Methods

    private func getFormatter(for currencyCode: String) -> NumberFormatter {
        if let existing = formatters[currencyCode] {
            return existing
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        formatters[currencyCode] = formatter
        return formatter
    }
}
