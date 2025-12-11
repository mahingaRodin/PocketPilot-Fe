//
//  Untitled.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

struct Expense: Codable, Identifiable {
    let id: String
    let userID: String
    let teamID: String?
    let amount: Double
    let currency: String
    let category: Category
    let description: String
    let date: Date
    let receiptURL: String?
    let location: Location?
    let tags: [String]
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case teamID = "team_id"
        case amount
        case currency
        case category
        case description
        case date
        case receiptURL = "receipt_url"
        case location
        case tags
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
