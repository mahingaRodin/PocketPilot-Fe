//
//  Untitled.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

struct AuthResponse: Codable, Sendable {
    let accessToken: String
    let refreshToken: String
    let user: User?
    let expiresIn: Int?
}
