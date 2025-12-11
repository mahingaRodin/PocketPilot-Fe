//
//  Untitled.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation
import KeychainAccess

class KeychainManager {
    static let shared = KeychainManager()
    
    private let keychain = Keychain(service: "com.yourcompany.pocketpilot")
        .accessibility(.afterFirstUnlock)
    
    private init() {}
    
    // MARK: - Token Management
    
    func saveTokens(accessToken: String, refreshToken: String) throws {
        try keychain.set(accessToken, key: Constants.Keychain.accessToken)
        try keychain.set(refreshToken, key: Constants.Keychain.refreshToken)
    }
    
    func getAccessToken() -> String? {
        try? keychain.get(Constants.Keychain.accessToken)
    }
    
    func getRefreshToken() -> String? {
        try? keychain.get(Constants.Keychain.refreshToken)
    }
    
    func clearTokens() {
        try? keychain.remove(Constants.Keychain.accessToken)
        try? keychain.remove(Constants.Keychain.refreshToken)
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
