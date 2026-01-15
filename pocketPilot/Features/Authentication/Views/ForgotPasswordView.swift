//
//  ForgotPasswordView.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    @State private var email: String = ""
    @State private var isLoading: Bool = false
    @State private var showSuccess: Bool = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    
    private let authManager = AuthManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "lock.rotation")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Forgot Password?")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Enter your email address and we'll send you instructions to reset your password")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    if showSuccess {
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                            
                            Text("Email Sent!")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Please check your email for password reset instructions")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    } else {
                        // Form
                        VStack(spacing: 20) {
                            CustomTextField(
                                icon: "envelope",
                                placeholder: "Enter your email",
                                text: $email,
                                keyboardType: .emailAddress
                            )
                            
                            if let error = errorMessage {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            PrimaryButton(
                                title: "Send Reset Link",
                                action: {
                                    Task {
                                        await resetPassword()
                                    }
                                },
                                isLoading: isLoading
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func resetPassword() async {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authManager.forgotPassword(email: email)
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    ForgotPasswordView()
}
