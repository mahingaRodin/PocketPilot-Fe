//
//  Budget.swift
//  pocketPilot
//
//  Created by headie-one on 01/21/26.
//

import Foundation

struct Budget: Codable, Identifiable, Sendable {
    let id: UUID
    let category: String
    let categoryDisplay: String?
    let categoryIcon: String?
    let amount: Double
    let period: String
    let startDate: Date
    let endDate: Date?
    let alertThreshold: Double
    let isActive: Bool
}

struct BudgetStatus: Codable, Identifiable, Sendable {
    let budget: Budget
    let spent: Double
    let remaining: Double
    let percentage: Double
    let status: String
    let daysRemaining: Int
    let averageDaily: Double
    let projectedTotal: Double
    let onTrack: Bool
    
    var id: UUID { budget.id }
    
    var statusColor: String {
        switch status {
        case "on_track": return "green"
        case "approaching": return "orange"
        case "warning": return "red"
        case "exceeded": return "red"
        default: return "gray"
        }
    }
    
    var statusIcon: String {
        switch status {
        case "on_track": return "checkmark.circle.fill"
        case "approaching": return "exclamationmark.triangle.fill"
        case "warning": return "exclamationmark.triangle.fill"
        case "exceeded": return "xmark.circle.fill"
        default: return "circle"
        }
    }
}

struct BudgetSummary: Codable, Sendable {
    let totalBudget: Double
    let totalSpent: Double
    let totalRemaining: Double
    let overallPercentage: Double
    let budgets: [BudgetStatus]
    let alerts: [BudgetAlert]
}

struct BudgetAlert: Codable, Identifiable, Sendable {
    let id: UUID
    let budgetId: UUID
    let alertType: String
    let thresholdPercentage: Double
    let triggeredAt: Date
    let isRead: Bool
    let message: String?
}

