import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager
    
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showError = false
    @State private var navigateToSignUp = false
    @State private var navigateToForgotPassword = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [.blue.opacity(0.6), .purple.opacity(0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        Spacer()
                            .frame(height: 60)
                        
                        // Logo and Title
                        VStack(spacing: 16) {
                            Image(systemName: "creditcard.circle.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(.white)
                            
                            Text("PocketPilot")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(.white)
                            
                            Text("Track expenses effortlessly")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.9))
                        }
                        .padding(.bottom, 30)
                        
                        // Login Form
                        VStack(spacing: 20) {
                            // Email Field
                            CustomTextField(
                                icon: "envelope.fill",
                                placeholder: "Email",
                                text: $email,
                                keyboardType: .emailAddress
                            )
                            
                            // Password Field
                            CustomSecureField(
                                icon: "lock.fill",
                                placeholder: "Password",
                                text: $password,
                                showPassword: $showPassword
                            )
                            
                            // Forgot Password
                            HStack {
                                Spacer()
                                Button {
                                    navigateToForgotPassword = true
                                } label: {
                                    Text("Forgot Password?")
                                        .font(.footnote)
                                        .foregroundStyle(.white)
                                }
                            }
                            
                            // Login Button
                            Button {
                                Task {
                                    await handleLogin()
                                }
                            } label: {
                                if authManager.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Login")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                            }
                            .disabled(authManager.isLoading || !isValidForm)
                            .opacity(isValidForm ? 1 : 0.6)
                            
                            // Sign Up Link
                            HStack {
                                Text("Don't have an account?")
                                    .foregroundStyle(.white.opacity(0.9))
                                
                                Button {
                                    navigateToSignUp = true
                                } label: {
                                    Text("Sign Up")
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)
                                }
                            }
                            .font(.subheadline)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 32)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToSignUp) {
                SignUpView()
            }
            .navigationDestination(isPresented: $navigateToForgotPassword) {
                ForgotPasswordView()
            }
            .alert("Login Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(authManager.errorMessage ?? "An error occurred")
            }
        }
    }
    
    private var isValidForm: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }
    
    private func handleLogin() async {
        do {
            try await authManager.login(email: email, password: password)
        } catch {
            showError = true
        }
    }
}
