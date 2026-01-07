//
//  Receipt.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation

struct Receipt: Codable, Identifiable {
    let id: String
    let expenseID: String
    let imageURL: String
    let thumbnailURL: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case expenseID = "expense_id"
        case imageURL = "image_url"
        case thumbnailURL = "thumbnail_url"
        case createdAt = "created_at"
    }
}

struct Location: Codable {
    let latitude: Double
    let longitude: Double
    let address: String?
    let city: String?
    let country: String?
}