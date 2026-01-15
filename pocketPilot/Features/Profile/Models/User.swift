//
//  User.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation

struct User: Codable, Identifiable, Sendable {
    let id: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let profileImageURL: String?
    let createdAt: Date?
    let updatedAt: Date?
    
    var name: String {
        "\(firstName ?? "") \(lastName ?? "")".trimmingCharacters(in: .whitespaces)
    }
}
