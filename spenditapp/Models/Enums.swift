//
//  Enums.swift
//  spenditapp
//
//  Created by RAYED AL NOOM on 2025-12-19.
//

import Foundation

// MARK: - Item Type

/// Represents the type of financial item in a spending plan
enum ItemType: String, Codable, CaseIterable {
    case outcome    // Expenses - reduces available funds
    case income     // Money coming in - increases available funds
    case savings    // Money set aside - reduces available but tracked separately

    var displayName: String {
        switch self {
        case .outcome: return "Expense"
        case .income: return "Income"
        case .savings: return "Savings"
        }
    }

    var systemColor: String {
        switch self {
        case .income: return "green"
        case .outcome: return "red"
        case .savings: return "blue"
        }
    }
}

// MARK: - Plan Status

/// Represents the current status of a spending plan
enum PlanStatus: String, Codable, CaseIterable {
    case draft      // Plan is being created, not yet started
    case active     // Current active plan
    case completed  // Plan period has ended
    case archived   // User has archived this plan

    var displayName: String {
        switch self {
        case .draft: return "Draft"
        case .active: return "Active"
        case .completed: return "Completed"
        case .archived: return "Archived"
        }
    }
}

// MARK: - Recurrence Type

/// Defines how frequently a plan repeats
enum RecurrenceType: String, Codable, CaseIterable {
    case monthly    // Repeats every month
    case biweekly   // Repeats every 2 weeks
    case weekly     // Repeats every week
    case custom     // User-defined interval (future feature)

    var displayName: String {
        switch self {
        case .monthly: return "Monthly"
        case .biweekly: return "Bi-weekly"
        case .weekly: return "Weekly"
        case .custom: return "Custom"
        }
    }

    /// Calculate next occurrence date
    func nextDate(from date: Date) -> Date {
        let calendar = Calendar.current
        switch self {
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        case .biweekly:
            return calendar.date(byAdding: .day, value: 14, to: date) ?? date
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
        case .custom:
            return date // TODO: Implement custom interval logic
        }
    }
}

// MARK: - Group Type

/// Defines the type of group planning
enum GroupType: String, Codable, CaseIterable {
    case yearly     // 12 monthly child plans
    case quarterly  // Future: 4 quarterly plans
    case custom     // Future: user-defined

    var displayName: String {
        switch self {
        case .yearly: return "Yearly"
        case .quarterly: return "Quarterly"
        case .custom: return "Custom"
        }
    }

    /// Number of child plans to create
    var childPlanCount: Int {
        switch self {
        case .yearly: return 12
        case .quarterly: return 4
        case .custom: return 1
        }
    }

    /// Calculate child plan dates from parent start date
    func childPlanDates(startingFrom startDate: Date) -> [(start: Date, end: Date)] {
        let calendar = Calendar.current
        var dates: [(start: Date, end: Date)] = []

        switch self {
        case .yearly:
            // Create 12 monthly periods
            for month in 0..<12 {
                guard let monthStart = calendar.date(byAdding: .month, value: month, to: startDate),
                      let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart),
                      let adjustedEnd = calendar.date(byAdding: .day, value: -1, to: monthEnd) else {
                    continue
                }
                dates.append((monthStart, adjustedEnd))
            }
        case .quarterly:
            // Create 4 quarterly periods
            for quarter in 0..<4 {
                guard let quarterStart = calendar.date(byAdding: .month, value: quarter * 3, to: startDate),
                      let quarterEnd = calendar.date(byAdding: .month, value: 3, to: quarterStart),
                      let adjustedEnd = calendar.date(byAdding: .day, value: -1, to: quarterEnd) else {
                    continue
                }
                dates.append((quarterStart, adjustedEnd))
            }
        case .custom:
            // Single period (same as parent)
            if let endDate = calendar.date(byAdding: .year, value: 1, to: startDate),
               let adjustedEnd = calendar.date(byAdding: .day, value: -1, to: endDate) {
                dates.append((startDate, adjustedEnd))
            }
        }

        return dates
    }
}
