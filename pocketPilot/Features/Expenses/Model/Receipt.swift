//
//  Receipt.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation

struct Receipt: Codable, Identifiable, Sendable {
    let id: String
    let expenseID: String
    let imageURL: String
    let thumbnailURL: String?
    let createdAt: Date
}

struct Location: Codable, Sendable {
    let latitude: Double
    let longitude: Double
    let address: String?
    let city: String?
    let country: String?
}