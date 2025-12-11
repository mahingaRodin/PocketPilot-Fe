//
//  User.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String
    let profileImageURL: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case profileImageURL = "profile_image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
