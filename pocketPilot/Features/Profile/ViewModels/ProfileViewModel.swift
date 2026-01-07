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
    
    func logout() {
        authManager.logout()
    }
}