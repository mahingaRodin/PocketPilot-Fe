//
//  BackendResponses.swift
//  pocketPilot
//
//  Created by headie-one on 15/01/26.
//

import Foundation

/// Matches the flat structure returned by the expenses endpoint
struct BackendExpenseResponse: Decodable, Sendable {
    let expenses: [Expense]
    let total: Int
    let perPage: Int
    let page: Int
    let totalAmount: Double
}

/// Matches the flat structure expected from the dashboard endpoint
struct BackendDashboardResponse: Decodable, Sendable {
    let totalExpenses: Double?
    let monthlyExpenses: Double?
    let categoryBreakdown: [CategoryBreakdown]?
    let recentExpenses: [Expense]?
    let monthlyComparison: MonthlyComparison?
    
    // Allow decoding from a direct DashboardData object if matched
    func toDashboardData() -> DashboardData {
        return DashboardData(
            totalExpenses: totalExpenses,
            monthlyExpenses: monthlyExpenses,
            categoryBreakdown: categoryBreakdown,
            recentExpenses: recentExpenses,
            monthlyComparison: monthlyComparison
        )
    }
}
