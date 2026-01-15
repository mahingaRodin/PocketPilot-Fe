//
//  DashboardData.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation

struct DashboardData: Codable, Sendable {
    let totalExpenses: Double?
    let monthlyExpenses: Double?
    let categoryBreakdown: [CategoryBreakdown]?
    let recentExpenses: [Expense]?
    let monthlyComparison: MonthlyComparison?
    
    // Provide a default empty state for new users
    static var empty: DashboardData {
        DashboardData(
            totalExpenses: 0,
            monthlyExpenses: 0,
            categoryBreakdown: [],
            recentExpenses: [],
            monthlyComparison: MonthlyComparison(currentMonth: 0, previousMonth: 0, changePercentage: 0)
        )
    }
}

struct CategoryBreakdown: Codable, Identifiable, Sendable {
    let category: Category
    let amount: Double
    let percentage: Double?
    let count: Int?
    
    // Use category ID as identifier
    var id: String {
        category.id
    }
    
    enum CodingKeys: String, CodingKey {
        case categoryString = "category"
        case total, amount, percentage, count
        case expenseCount = "expense_count"
        case categoryDisplay, categoryIcon
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            // Handle amount from either 'amount' or 'total'
            if let total = try? container.decode(Double.self, forKey: .total) {
                amount = total
            } else {
                amount = try container.decodeIfPresent(Double.self, forKey: .amount) ?? 0.0
            }
            
            percentage = try container.decodeIfPresent(Double.self, forKey: .percentage)
            
            // Handle count from multiple potential keys and formats
            if let countInt = try? container.decode(Int.self, forKey: .count) {
                count = countInt
            } else if let countString = try? container.decode(String.self, forKey: .count), let countInt = Int(countString) {
                count = countInt
            } else if let expenseCount = try? container.decode(Int.self, forKey: .expenseCount) {
                count = expenseCount
            } else if let totalCount = try? container.decode(Int.self, forKey: .total) {
                // Some backends use 'total' for count if amount is separate
                count = totalCount
            } else {
                count = try container.decodeIfPresent(Int.self, forKey: .count)
            }
            
            // Handle Category object from string/fields
            if let catObj = try? container.decode(Category.self, forKey: .categoryString) {
                category = catObj
            } else {
                let catName = try container.decodeIfPresent(String.self, forKey: .categoryString) ?? "Other"
                let catDisplay = try container.decodeIfPresent(String.self, forKey: .categoryDisplay) ?? catName
                
                // Try to find a matching default category for icon and color
                let defaultMatch = Category.findMatch(for: catName)
                
                let catIcon = try container.decodeIfPresent(String.self, forKey: .categoryIcon) 
                    ?? defaultMatch?.icon 
                    ?? "ellipsis.circle"
                
                let catColor = defaultMatch?.color ?? "#95A5A6"
                
                category = Category(
                    id: defaultMatch?.id ?? catName.lowercased(),
                    name: catDisplay,
                    icon: catIcon,
                    color: catColor
                )
            }
        } catch {
            print("DEBUG: [CategoryBreakdown] Decoding failure: \(error)")
            throw error
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(category.name, forKey: .categoryString)
        try container.encode(amount, forKey: .total)
        try container.encodeIfPresent(percentage, forKey: .percentage)
        try container.encodeIfPresent(count, forKey: .count)
    }
}

struct MonthlyComparison: Codable, Sendable {
    let currentMonth: Double
    let previousMonth: Double
    let changePercentage: Double
}
