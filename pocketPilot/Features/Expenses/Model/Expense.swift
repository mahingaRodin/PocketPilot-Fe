//
//  Untitled.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation

struct Expense: Codable, Identifiable, Sendable {
    let id: String
    let userID: String?
    let teamID: String?
    let amount: Double
    let currency: String?
    let category: Category
    let description: String
    let date: Date
    let receiptURL: String?
    let items: [ReceiptItem]?
    let notes: String?
    let tags: [String]?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, amount, currency, description, date, notes, tags, items, receiptURL
        case userID = "userId"
        case teamID = "teamId"
        case categoryString = "category"
        case categoryIcon, categoryDisplay
        case createdAt, updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            id = try container.decode(String.self, forKey: .id)
            userID = try container.decodeIfPresent(String.self, forKey: .userID)
            teamID = try container.decodeIfPresent(String.self, forKey: .teamID)
            amount = try container.decode(Double.self, forKey: .amount)
            currency = try container.decodeIfPresent(String.self, forKey: .currency) ?? "USD"
            description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
            notes = try container.decodeIfPresent(String.self, forKey: .notes)
            tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
            
            // Handle dates with defaults
            date = try container.decodeIfPresent(Date.self, forKey: .date) ?? Date()
            createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
            updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
            receiptURL = try container.decodeIfPresent(String.self, forKey: .receiptURL)
            items = try container.decodeIfPresent([ReceiptItem].self, forKey: .items)
            
            // Handle Category - backend sends string, model wants Category object
            if let categoryObj = try? container.decode(Category.self, forKey: .categoryString) {
                category = categoryObj
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
            print("DEBUG: [Expense] Decoding failure for id \( (try? container.decode(String.self, forKey: .id)) ?? "unknown" ): \(error)")
            throw error
        }
    }
    
    // Memberwise initializer for manual creation
    init(id: String, userID: String?, teamID: String?, amount: Double, currency: String?, category: Category, description: String, date: Date, receiptURL: String?, items: [ReceiptItem]? = nil, notes: String?, tags: [String], createdAt: Date, updatedAt: Date) {
        self.id = id
        self.userID = userID
        self.teamID = teamID
        self.amount = amount
        self.currency = currency
        self.category = category
        self.description = description
        self.date = date
        self.receiptURL = receiptURL
        self.items = items
        self.notes = notes
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(userID, forKey: .userID)
        try container.encodeIfPresent(teamID, forKey: .teamID)
        try container.encode(amount, forKey: .amount)
        try container.encodeIfPresent(currency, forKey: .currency)
        try container.encode(description, forKey: .description)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encodeIfPresent(tags, forKey: .tags)
        try container.encodeIfPresent(items, forKey: .items)
        try container.encodeIfPresent(receiptURL, forKey: .receiptURL)
        try container.encode(date, forKey: .date)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        
        // Encode category as string for backend compatibility
        try container.encode(category.name, forKey: .categoryString)
    }
}
