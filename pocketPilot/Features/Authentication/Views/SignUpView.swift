//
//  SignUpView.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import SwiftUI

struct SignUpView: View {
    @State private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Create Account")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Join PocketPilot to start tracking your expenses")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Form
                    VStack(spacing: 20) {
                        CustomTextField(
                            title: "Full Name",
                            text: $viewModel.name,
                            placeholder: "Enter your full name"
                        )
                        
                        CustomTextField(
                            title: "Email",
                            text: $viewModel.email,
                            placeholder: "Enter your email",
                            keyboardType: .emailAddress
                        )
                        
                        CustomTextField(
                            title: "Password",
                            text: $viewModel.password,
                            placeholder: "Enter your password",
                            isSecure: true
                        )
                        
                        CustomTextField(
                            title: "Confirm Password",
                            text: $viewModel.confirmPassword,
                            placeholder: "Confirm your password",
                            isSecure: true
                        )
                        
                        if viewModel.showError, let error = viewModel.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        PrimaryButton(
                            title: "Sign Up",
                            action: {
                                Task {
                                    await viewModel.signUp()
                                }
                            },
                            isLoading: viewModel.isLoading
                        )
                    }
                    .padding(.horizontal)
                    
                    // Login Link
                    HStack {
                        Text("Already have an account?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button("Login") {
                            dismiss()
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    }
                    .padding(.top)
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
}

#Preview {
    SignUpView()
}
