//
//  LoginView.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import SwiftUI

struct LoginView: View {
    @State private var viewModel = AuthViewModel()
    @State private var showSignUp = false
    @State private var showForgotPassword = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Logo/Header
                    VStack(spacing: 16) {
                        Image(systemName: "wallet.pass.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("PocketPilot")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Track your expenses effortlessly")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Form
                    VStack(spacing: 20) {
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
                        
                        HStack {
                            Spacer()
                            Button("Forgot Password?") {
                                showForgotPassword = true
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                        
                        if viewModel.showError, let error = viewModel.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        PrimaryButton(
                            title: "Login",
                            action: {
                                Task {
                                    await viewModel.login()
                                }
                            },
                            isLoading: viewModel.isLoading
                        )
                    }
                    .padding(.horizontal)
                    
                    // Sign Up Link
                    HStack {
                        Text("Don't have an account?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button("Sign Up") {
                            showSignUp = true
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
            .navigationDestination(isPresented: $showForgotPassword) {
                ForgotPasswordView()
            }
        }
    }
}

#Preview {
    LoginView()
}