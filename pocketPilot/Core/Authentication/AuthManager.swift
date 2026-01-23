//
//  AuthManager.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation
import Observation
import Alamofire

@MainActor
@Observable
class AuthManager {
    static let shared = AuthManager()
    
    var isAuthenticated: Bool = false
    var currentUser: User?
    var isLoading: Bool = false
    var errorMessage: String?
    
    // Welcome message properties
    var welcomeMessage: String?
    var showWelcomeMessage: Bool = false
    
    private let keychainManager = KeychainManager.shared
    private let apiClient = APIClient.shared
    
    // Low-level response to ensure redirection even if full data decoding fails
    private struct BaseResponse: Decodable {
        let success: Bool
        let error: APIErrorDetail?
    }
    
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
            let data = try await apiClient.requestData(
                .login,
                method: .post,
                parameters: request.dictionary
            )
            
            let decoder = JSONDecoder.api
            
            // 1. Try to decode success status first (BaseResponse)
            let baseResponse = try? decoder.decode(BaseResponse.self, from: data)
            
            // If the request reached here, it's a 2xx response. 
            // We should proceed if success is true, OR if the decoding failed but it's not a known error payload.
            if baseResponse?.success == true || (baseResponse == nil && !data.isEmpty) {
                // 2. Try to decode detailed data
                // We use two attempts: one with the standard wrapper, and one as a fallback for the raw payload
                let authResponse = (try? decoder.decode(MainActorAPIResponse<AuthResponse>.self, from: data))?.data 
                    ?? (try? decoder.decode(AuthResponse.self, from: data))
                
                if let details = authResponse {
                    print("DEBUG: Received tokens. Attempting to save to keychain...")
                    // SAVE TOKENS
                    do {
                        try keychainManager.saveTokens(
                            accessToken: details.accessToken,
                            refreshToken: details.refreshToken
                        )
                        
                        if let user = details.user {
                            try? keychainManager.saveUserID(user.id)
                            currentUser = user
                            
                            // Set welcome message
                            welcomeMessage = "Welcome back \(user.firstName ?? "") 😁 to PocketPilot"
                            showWelcomeMessage = true
                        }
                        
                        isAuthenticated = true
                        WebSocketManager.shared.connect()
                    } catch {
                        print("DEBUG: FAILED to save or verify tokens: \(error)")
                        errorMessage = "Security storage failure: \(error.localizedDescription)"
                        throw APIError.unknown("Keychain error")
                    }
                } else {
                    let rawString = String(data: data, encoding: .utf8) ?? "binary"
                    print("DEBUG: Login succeeded but AuthResponse decoding failed. Raw data: \(rawString)")
                    errorMessage = "Session data format mismatch"
                    throw APIError.unknown("Decoding error")
                }
                
            } else if let error = baseResponse?.error {
                 errorMessage = error.message
                 throw APIError.serverError(0, error.message)
            } else {
                 isAuthenticated = true
                 WebSocketManager.shared.connect()
            }
            
        } catch let error as APIError {
            // Special handling for login unauthorized errors
            if case .unauthorized = error {
                errorMessage = "Incorrect email or password"
                throw APIError.serverError(401, "Incorrect email or password")
            }
            errorMessage = error.localizedDescription
            throw error
        } catch {
             errorMessage = error.localizedDescription
             throw APIError.unknown(error.localizedDescription)
        }
    }
    
    // MARK: - Sign Up
    
    func signUp(email: String, password: String, firstName: String, lastName: String, confirmPassword: String) async throws {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            let request = SignUpRequest(email: email, password: password, firstName: firstName, lastName: lastName, confirmPassword: confirmPassword)
            let data = try await apiClient.requestData(
                .signup,
                method: .post,
                parameters: request.dictionary
            )
            
            let decoder = JSONDecoder.api
            
            // 1. Try to decode success status first (BaseResponse)
            let baseResponse = try? decoder.decode(BaseResponse.self, from: data)
            
            if baseResponse?.success == true || (baseResponse == nil && !data.isEmpty) {
                // 2. Try to decode detailed data
                let authResponse = (try? decoder.decode(MainActorAPIResponse<AuthResponse>.self, from: data))?.data 
                    ?? (try? decoder.decode(AuthResponse.self, from: data))
                
                if let details = authResponse {
                    print("DEBUG: Received tokens during signup. Saving...")
                    do {
                        try keychainManager.saveTokens(
                            accessToken: details.accessToken,
                            refreshToken: details.refreshToken
                        )
                        
                        if let user = details.user {
                            try? keychainManager.saveUserID(user.id)
                            currentUser = user
                            
                            // Set welcome message for signup
                            welcomeMessage = "Welcome to PocketPilot, \(user.firstName ?? "")..."
                            showWelcomeMessage = true
                        }
                        
                        isAuthenticated = true
                        WebSocketManager.shared.connect()
                    } catch {
                        print("DEBUG: FAILED to save tokens after signup: \(error)")
                        errorMessage = "Security storage failure"
                        throw APIError.unknown("Keychain error")
                    }
                } else {
                    let rawString = String(data: data, encoding: .utf8) ?? "binary"
                    print("DEBUG: Signup succeeded but AuthResponse decoding failed. Raw data: \(rawString)")
                    errorMessage = "Session data format mismatch"
                    throw APIError.unknown("Decoding error")
                }
                
            } else if let error = baseResponse?.error {
                 errorMessage = error.message
                 throw APIError.serverError(0, error.message)
            } else {
                 errorMessage = "Unexpected server response"
                 throw APIError.unknown("Missing authentication data")
            }
            
        } catch let error as APIError {
            errorMessage = error.localizedDescription
            throw error
        } catch {
             errorMessage = error.localizedDescription
             throw APIError.unknown(error.localizedDescription)
        }
    }
    
    // MARK: - Logout
    
    func logout() {
        // 1. Instantly update UI and clear local data
        isAuthenticated = false
        currentUser = nil
        errorMessage = nil
        keychainManager.clearAllData()
        WebSocketManager.shared.disconnect()
        
        // 2. Best-effort background notification to backend
        let token = keychainManager.getAccessToken()
        
        Task {
            guard let _ = token else { return }
            do {
                let url = Constants.API.baseURL + APIEndpoint.logout.path
                // Use the stateless refreshRequest functionality to avoid interception loops
                _ = try? await apiClient.refreshRequest(url: url, parameters: [:])
            } catch {
                print("Silent logout notification failed: \(error)")
            }
        }
    }
    
    // MARK: - Get Current User
    
    func getCurrentUser() async throws {
        do {
            let data = try await apiClient.requestData(.me)
            let decoder = JSONDecoder.api
            let response = try decoder.decode(MainActorAPIResponse<User>.self, from: data)
            
            if response.success, let user = response.data {
                currentUser = user
            } else if let error = response.error {
                 logout()
                 throw APIError.serverError(0, error.message)
            }
        } catch {
            print("DEBUG: getCurrentUser failed: \(error.localizedDescription). Checking if we should logout...")
            // Avoid calling logout manually if it's already handled by the interceptor's retry failure
            // but for safety in this specific boot-up check, we keep it if it's a terminal error.
            if case APIError.unauthorized = error {
                print("DEBUG: Terminal 401 during profile fetch. Clearing session.")
                logout()
            }
            throw error
        }
    }
    
    // MARK: - Update Profile
    
    func updateProfile(firstName: String?, lastName: String?, profileImage: Data?) async throws {
        isLoading = true
        defer { isLoading = false }
        
        var parameters: [String: Any]? = nil
        if firstName != nil || lastName != nil {
            parameters = [:]
            if let firstName = firstName { parameters?["firstName"] = firstName }
            if let lastName = lastName { parameters?["lastName"] = lastName }
        }
        
        if let imageData = profileImage {
            let data = try await apiClient.uploadData(
                .updateProfile,
                data: imageData,
                name: "profile_image",
                fileName: "profile.jpg",
                mimeType: "image/jpeg",
                parameters: parameters
            )
            
            let decoder = JSONDecoder.api
            var decodedUser: User?
            
            // Try to see if backend returned tokens as well (essential for keeping session alive if tokens rotate)
            if let response = try? decoder.decode(MainActorAPIResponse<AuthResponse>.self, from: data), let details = response.data {
                decodedUser = details.user
                if !details.accessToken.isEmpty {
                    print("DEBUG: Received new tokens after profile upload. Saving...")
                    try? keychainManager.saveTokens(accessToken: details.accessToken, refreshToken: details.refreshToken)
                }
            } else if let response = try? decoder.decode(MainActorAPIResponse<User>.self, from: data) {
                if response.success, let user = response.data {
                    decodedUser = user
                } else if let error = response.error {
                    throw APIError.serverError(0, error.message)
                }
            } else if let user = try? decoder.decode(User.self, from: data) {
                decodedUser = user
            }
            
            if let user = decodedUser {
                currentUser = user
            } else {
                let rawString = String(data: data, encoding: .utf8) ?? "binary"
                print("DEBUG: Profile update (multipart) succeeded but User decoding failed. Raw data: \(rawString)")
                throw APIError.decodingError("Failed to decode user profile after upload.")
            }
            
        } else if let parameters = parameters {
            let data = try await apiClient.requestData(
                .updateProfile,
                method: .put,
                parameters: parameters
            )
            let decoder = JSONDecoder.api
            var decodedUser: User?
            
            // Try to see if backend returned tokens as well
            if let response = try? decoder.decode(MainActorAPIResponse<AuthResponse>.self, from: data), let details = response.data {
                decodedUser = details.user
                if !details.accessToken.isEmpty {
                    print("DEBUG: Received new tokens after profile update. Saving...")
                    try? keychainManager.saveTokens(accessToken: details.accessToken, refreshToken: details.refreshToken)
                }
            } else if let response = try? decoder.decode(MainActorAPIResponse<User>.self, from: data) {
                if response.success, let user = response.data {
                    decodedUser = user
                } else if let error = response.error {
                    throw APIError.serverError(0, error.message)
                }
            } else if let user = try? decoder.decode(User.self, from: data) {
                decodedUser = user
            }
            
            if let user = decodedUser {
                currentUser = user
            } else {
                let rawString = String(data: data, encoding: .utf8) ?? "binary"
                print("DEBUG: Profile update (put) succeeded but User decoding failed. Raw data: \(rawString)")
                throw APIError.decodingError("Failed to decode user profile after update.")
            }
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
        
        let data = try await apiClient.requestData(
            .changePassword,
            method: .post,
            parameters: parameters
        )
        let decoder = JSONDecoder.api
        let response = try decoder.decode(MainActorAPIResponse<EmptyResponse>.self, from: data)
         if !response.success, let error = response.error {
            throw APIError.serverError(0, error.message)
        }
    }
    
    // MARK: - Forgot Password
    
    func forgotPassword(email: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let data = try await apiClient.requestData(
            .forgotPassword,
            method: .post,
            parameters: ["email": email]
        )
        let decoder = JSONDecoder.api
        let response = try decoder.decode(MainActorAPIResponse<EmptyResponse>.self, from: data)
         if !response.success, let error = response.error {
            throw APIError.serverError(0, error.message)
        }
    }
    
    // MARK: - Reset Password
    
    func resetPassword(token: String, newPassword: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let parameters: [String: Any] = [
            "token": token,
            "password": newPassword
        ]
        
        let data = try await apiClient.requestData(
            .resetPassword,
            method: .post,
            parameters: parameters
        )
        let decoder = JSONDecoder.api
        let response = try decoder.decode(MainActorAPIResponse<EmptyResponse>.self, from: data)
         if !response.success, let error = response.error {
            throw APIError.serverError(0, error.message)
        }
    }
    
    // MARK: - Helper Methods
    
    private func checkAuthStatus() {
        if let token = keychainManager.getAccessToken(),
           !token.isEmpty {
            print("DEBUG: [Auth] Found existing session on boot. Restoring...")
            isAuthenticated = true
            
            // Fetch current user info
            Task {
                print("DEBUG: [Auth] Fetching profile for restored session...")
                try? await getCurrentUser()
            }
        } else {
            print("DEBUG: [Auth] No session found on boot.")
        }
    }
}


