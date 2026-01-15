
//
//  LoginRequest.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

struct LoginRequest: Codable, Sendable {
    let email: String
    let password: String
    
    var dictionary: [String: Any] {
        return [
            "email": email,
            "password": password
        ]
    }
}
