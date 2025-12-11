//
//  DashboardData.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

struct DashboardData: Codable {
    let totalExpenses: Double
    let monthlyExpenses: Double
    let categoryBreakdown: [CategoryBreakdown]
    let recentExpenses: [Expense]
    let monthlyComparison: MonthlyComparison
    
    enum CodingKeys: String, CodingKey {
        case totalExpenses = "total_expenses"
        case monthlyExpenses = "monthly_expenses"
        case categoryBreakdown = "category_breakdown"
        case recentExpenses = "recent_expenses"
        case monthlyComparison = "monthly_comparison"
    }
}

struct CategoryBreakdown: Codable, Identifiable {
    let id = UUID()
    let category: Category
    let amount: Double
    let percentage: Double
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case category
        case amount
        case percentage
        case count
    }
}

struct MonthlyComparison: Codable {
    let currentMonth: Double
    let previousMonth: Double
    let changePercentage: Double
    
    enum CodingKeys: String, CodingKey {
        case currentMonth = "current_month"
        case previousMonth = "previous_month"
        case changePercentage = "change_percentage"
    }
}
