//
//  AuthViewModel.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation
import Observation

@Observable
class AuthViewModel {
    var email: String = ""
    var password: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var confirmPassword: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var showError: Bool = false
    
    private let authManager = AuthManager.shared
    
    var isAuthenticated: Bool {
        authManager.isAuthenticated
    }
    
    // MARK: - Login
    
    func login() async {
        isLoading = true
        errorMessage = nil
        showError = false
        
        do {
            try await authManager.login(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    // MARK: - Sign Up
    
    func signUp() async {
        guard validateSignUp() else { return }
        
        isLoading = true
        errorMessage = nil
        showError = false
        
        do {
            try await authManager.signUp(email: email, password: password, firstName: firstName, lastName: lastName, confirmPassword: confirmPassword)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    // MARK: - Validation
    
    private func validateSignUp() -> Bool {
        if firstName.isEmpty {
            errorMessage = "First name is required"
            showError = true
            return false
        }
        
        if lastName.isEmpty {
            errorMessage = "Last name is required"
            showError = true
            return false
        }
        
        if !isValidEmail(email) {
            errorMessage = "Please enter a valid email address"
            showError = true
            return false
        }
        
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            showError = true
            return false
        }
        
        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            showError = true
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}