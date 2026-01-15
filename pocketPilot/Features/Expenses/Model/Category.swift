//
//  Category.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation

struct Category: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let icon: String?
    let color: String?
    
    static let defaultCategories: [Category] = [
        Category(id: "1", name: "Food & Dining", icon: "fork.knife", color: "#FF6B6B"),
        Category(id: "2", name: "Transportation", icon: "car.fill", color: "#4ECDC4"),
        Category(id: "3", name: "Shopping", icon: "bag.fill", color: "#45B7D1"),
        Category(id: "4", name: "Bills & Utilities", icon: "bolt.fill", color: "#FFA07A"),
        Category(id: "5", name: "Entertainment", icon: "tv.fill", color: "#98D8C8"),
        Category(id: "6", name: "Healthcare", icon: "cross.case.fill", color: "#F7DC6F"),
        Category(id: "7", name: "Education", icon: "book.fill", color: "#BB8FCE"),
        Category(id: "8", name: "Travel", icon: "airplane", color: "#85C1E2"),
        Category(id: "9", name: "Other", icon: "ellipsis.circle.fill", color: "#95A5A6")
    ]
}