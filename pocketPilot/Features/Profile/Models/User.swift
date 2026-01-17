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
    let profilePictureURL: String?
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, email, firstName, lastName, profilePictureURL, createdAt, updatedAt
        case first_name, last_name, profile_picture_url, created_at, updated_at
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // id is required
        id = try container.decode(String.self, forKey: .id)
        
        // Try camelCase then snake_case for optional fields
        email = try container.decodeIfPresent(String.self, forKey: .email)
        
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
            ?? container.decodeIfPresent(String.self, forKey: .first_name)
        
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
            ?? container.decodeIfPresent(String.self, forKey: .last_name)
        
        profilePictureURL = try container.decodeIfPresent(String.self, forKey: .profilePictureURL)
            ?? container.decodeIfPresent(String.self, forKey: .profile_picture_url)
        
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
            ?? container.decodeIfPresent(Date.self, forKey: .created_at)
        
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
            ?? container.decodeIfPresent(Date.self, forKey: .updated_at)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(profilePictureURL, forKey: .profilePictureURL)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
    }
    
    var name: String {
        "\(firstName ?? "") \(lastName ?? "")".trimmingCharacters(in: .whitespaces)
    }
}
