//
//  AuthManager.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation
import Observation

@Observable
class AuthManager {
    static let shared = AuthManager()
    
    var isAuthenticated: Bool = false
    var currentUser: User?
    var isLoading: Bool = false
    var errorMessage: String?
    
    private let keychainManager = KeychainManager.shared
    private let apiClient = APIClient.shared
    
    private init() {
        checkAuthStatus()
    }
    
    // MARK: - Login
    
    func login(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            let request = LoginRequest(email: email, password: password)
            let response: AuthResponse = try await apiClient.request(
                .login,
                method: .post,
                parameters: request.dictionary
            )
            
            try keychainManager.saveTokens(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken
            )
            try keychainManager.saveUserID(response.user.id)
            
            currentUser = response.user
            isAuthenticated = true
            
            // Connect to WebSocket after successful login
            WebSocketManager.shared.connect()
            
        } catch let error as APIError {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Sign Up
    
    func signUp(email: String, password: String, name: String) async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            let request = SignUpRequest(email: email, password: password, name: name)
            let response: AuthResponse = try await apiClient.request(
                .signup,
                method: .post,
                parameters: request.dictionary
            )
            
            try keychainManager.saveTokens(
                accessToken: response.accessToken,
                refreshToken: response.refreshToken
            )
            try keychainManager.saveUserID(response.user.id)
            
            currentUser = response.user
            isAuthenticated = true
            
            WebSocketManager.shared.connect()
            
        } catch let error as APIError {
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Logout
    
    func logout() {
        Task {
            // Attempt to notify backend
            try? await apiClient.request(
                .logout,
                method: .post
            ) as EmptyResponse
            
            // Clear local data
            keychainManager.clearAllData()
            WebSocketManager.shared.disconnect()
            
            await MainActor.run {
                isAuthenticated = false
                currentUser = nil
                errorMessage = nil
            }
        }
    }
    
    // MARK: - Get Current User
    
    func getCurrentUser() async throws {
        do {
            let user: User = try await apiClient.request(.me)
            currentUser = user
        } catch {
            // If fetching user fails, logout
            logout()
            throw error
        }
    }
    
    // MARK: - Update Profile
    
    func updateProfile(name: String?, profileImage: Data?) async throws {
        isLoading = true
        defer { isLoading = false }
        
        if let imageData = profileImage {
            let user: User = try await apiClient.upload(
                .updateProfile,
                data: imageData,
                name: "profile_image",
                fileName: "profile.jpg",
                mimeType: "image/jpeg",
                parameters: name != nil ? ["name": name!] : nil
            )
            currentUser = user
        } else if let name = name {
            let user: User = try await apiClient.request(
                .updateProfile,
                method: .put,
                parameters: ["name": name]
            )
            currentUser = user
        }
    }
    
    // MARK: - Change Password
    
    func changePassword(currentPassword: String, newPassword: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let parameters: [String: Any] = [
            "current_password": currentPassword,
            "new_password": newPassword
        ]
        
        let _: EmptyResponse = try await apiClient.request(
            .changePassword,
            method: .post,
            parameters: parameters
        )
    }
    
    // MARK: - Forgot Password
    
    func forgotPassword(email: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let _: EmptyResponse = try await apiClient.request(
            .forgotPassword,
            method: .post,
            parameters: ["email": email]
        )
    }
    
    // MARK: - Reset Password
    
    func resetPassword(token: String, newPassword: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let parameters: [String: Any] = [
            "token": token,
            "password": newPassword
        ]
        
        let _: EmptyResponse = try await apiClient.request(
            .resetPassword,
            method: .post,
            parameters: parameters
        )
    }
    
    // MARK: - Helper Methods
    
    private func checkAuthStatus() {
        if let token = keychainManager.getAccessToken(),
           !token.isEmpty {
            isAuthenticated = true
            
            // Fetch current user info
            Task {
                try? await getCurrentUser()
            }
        }
    }
}

// MARK: - Empty Response (for endpoints with no data)
struct EmptyResponse: Codable {}

// MARK: - Encodable Extension
extension Encodable {
    var dictionary: [String: Any] {
        guard let data = try? JSONEncoder().encode(self),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return [:]
        }
        return dict
    }
}
