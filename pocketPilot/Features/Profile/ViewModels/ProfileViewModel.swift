//
//  ProfileViewModel.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation
import UIKit
import Observation

@Observable
class ProfileViewModel {
    var user: User?
    var isLoading: Bool = false
    var errorMessage: String?
    var profileVersion: Int = 0
    
    private let authManager = AuthManager.shared
    private let apiClient = APIClient.shared
    
    var currentUser: User? {
        authManager.currentUser
    }
    
    init() {
        user = authManager.currentUser
    }
    
    func loadProfile() {
        user = authManager.currentUser
    }
    
    func updateProfile(firstName: String, lastName: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authManager.updateProfile(firstName: firstName, lastName: lastName, profileImage: nil)
            user = authManager.currentUser
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
        
        isLoading = false
    }
    
    // MARK: - Profile Picture Management
    
    func uploadProfilePicture(_ image: UIImage) async {
        isLoading = true
        errorMessage = nil
        
        print("DEBUG: [ProfilePicture] Starting upload...")
        
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            errorMessage = "Failed to process image"
            isLoading = false
            print("DEBUG: [ProfilePicture] Failed to convert image to JPEG")
            return
        }
        
        print("DEBUG: [ProfilePicture] Image data size: \(imageData.count) bytes")
        
        do {
            guard let userId = currentUser?.id else {
                errorMessage = "User ID not found"
                isLoading = false
                return
            }
            
            let endpoint: APIEndpoint = currentUser?.profilePictureURL == nil ? .uploadProfilePicture(userId) : .updateProfilePicture(userId)
            print("DEBUG: [ProfilePicture] Using endpoint: \(endpoint)")
            
            let data = try await apiClient.uploadData(
                endpoint,
                data: imageData,
                name: "file",
                fileName: "profile.jpg",
                mimeType: "image/jpeg"
            )
            
            if let json = String(data: data, encoding: .utf8) {
                print("DEBUG: [ProfilePicture] Upload response: \(json)")
            }
            
            let decoder = JSONDecoder.api
            
            // Try to decode updated user/tokens
            if let response = try? decoder.decode(MainActorAPIResponse<AuthResponse>.self, from: data),
                let details = response.data {
                 print("DEBUG: [ProfilePicture] Decoded AuthResponse with tokens. Saving...")
                 try? KeychainManager.shared.saveTokens(accessToken: details.accessToken, refreshToken: details.refreshToken)
                 if let updatedUser = details.user {
                     user = updatedUser
                     AuthManager.shared.currentUser = updatedUser
                 }
            } else if let response = try? decoder.decode(MainActorAPIResponse<User>.self, from: data),
               let updatedUser = response.data {
                print("DEBUG: [ProfilePicture] Decoded user with URL: \(updatedUser.profilePictureURL ?? "nil")")
                user = updatedUser
                AuthManager.shared.currentUser = updatedUser
                print("DEBUG: [ProfilePicture] User state updated successfully")
            } else if let updatedUser = try? decoder.decode(User.self, from: data) {
                print("DEBUG: [ProfilePicture] Decoded flat user with URL: \(updatedUser.profilePictureURL ?? "nil")")
                user = updatedUser
                AuthManager.shared.currentUser = updatedUser
                print("DEBUG: [ProfilePicture] User state updated successfully")
            } else {
                print("DEBUG: [ProfilePicture] Failed to decode user from response")
            }
            
        } catch {
            print("DEBUG: [ProfilePicture] Upload error: \(error)")
            errorMessage = "Failed to upload profile picture: \(error.localizedDescription)"
        }
        
        isLoading = false
        profileVersion += 1
        print("DEBUG: [ProfilePicture] Upload complete. Current user URL: \(user?.profilePictureURL ?? "nil")")
    }
    
    func deleteProfilePicture() async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let userId = currentUser?.id else {
                errorMessage = "User ID not found"
                isLoading = false
                return
            }
            
            let data = try await apiClient.requestData(
                .deleteProfilePicture(userId)
            )
            
            let decoder = JSONDecoder.api
            
            // Try to decode updated user
            if let response = try? decoder.decode(MainActorAPIResponse<User>.self, from: data),
               let updatedUser = response.data {
                user = updatedUser
                AuthManager.shared.currentUser = updatedUser
            } else if let updatedUser = try? decoder.decode(User.self, from: data) {
                user = updatedUser
                AuthManager.shared.currentUser = updatedUser
            }
            
        } catch {
            errorMessage = "Failed to delete profile picture: \(error.localizedDescription)"
        }
        
        isLoading = false
        profileVersion += 1
    }
    
    func logout() {
        authManager.logout()
    }
}
