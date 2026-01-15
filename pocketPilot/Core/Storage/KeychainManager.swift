//
//  Untitled.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation
import KeychainAccess

final class KeychainManager: @unchecked Sendable {
    static let shared = KeychainManager()
    
    private let keychain = Keychain(service: "com.yourcompany.pocketpilot")
        .accessibility(.afterFirstUnlock)
    
    private init() {}
    
    // MARK: - Token Management
    
    func saveTokens(accessToken: String, refreshToken: String) throws {
        try keychain.set(accessToken, key: "access_token")
        try keychain.set(refreshToken, key: "refresh_token")
    }
    
    func getAccessToken() -> String? {
        try? keychain.get("access_token")
    }
    
    func getRefreshToken() -> String? {
        try? keychain.get("refresh_token")
    }
    
    func clearTokens() {
        try? keychain.remove("access_token")
        try? keychain.remove("refresh_token")
    }
    
    // MARK: - User Data
    
    func saveUserID(_ userID: String) throws {
        try keychain.set(userID, key: "user_id")
    }
    
    func getUserID() -> String? {
        try? keychain.get("user_id")
    }
    
    func clearAllData() {
        try? keychain.removeAll()
    }
}
