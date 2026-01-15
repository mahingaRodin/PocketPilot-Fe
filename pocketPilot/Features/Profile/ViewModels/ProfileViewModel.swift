//
//  ProfileViewModel.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation
import Observation

@Observable
class ProfileViewModel {
    var user: User?
    var isLoading: Bool = false
    var errorMessage: String?
    
    private let authManager = AuthManager.shared
    
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
    
    func logout() {
        authManager.logout()
    }
}
