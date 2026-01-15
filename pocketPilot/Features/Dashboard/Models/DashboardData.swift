//
//  DashboardData.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation

struct DashboardData: Codable, Sendable {
    let totalExpenses: Double
    let monthlyExpenses: Double
    let categoryBreakdown: [CategoryBreakdown]
    let recentExpenses: [Expense]
    let monthlyComparison: MonthlyComparison
}

struct CategoryBreakdown: Codable, Identifiable, Sendable {
    let category: Category
    let amount: Double
    let percentage: Double
    let count: Int
    
    // Use category ID as identifier
    var id: String {
        category.id
    }
}

struct MonthlyComparison: Codable, Sendable {
    let currentMonth: Double
    let previousMonth: Double
    let changePercentage: Double
}
