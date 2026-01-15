//
//  Untitled.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation

struct Expense: Codable, Identifiable, Sendable {
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
}
