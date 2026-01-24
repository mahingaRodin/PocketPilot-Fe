import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager
    
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showError = false
    @State private var navigateToSignUp = false
    @State private var navigateToForgotPassword = false
    
    // Animation States
    @State private var isAnimating = false
    @State private var appearScale = 0.8
    @State private var appearOpacity = 0.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Animated Immersive Background
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    // Dancing Blur 1
                    Circle()
                        .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 400, height: 400)
                        .blur(radius: 80)
                        .offset(x: isAnimating ? -100 : 100, y: isAnimating ? -200 : 100)
                        .opacity(0.6)
                    
                    // Dancing Blur 2
                    Circle()
                        .fill(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .offset(x: isAnimating ? 150 : -50, y: isAnimating ? 100 : -150)
                        .opacity(0.5)
                }
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                        isAnimating = true
                    }
                }
                
                ScrollView {
                    VStack(spacing: 32) {
                        Spacer().frame(height: 40)
                        
                        // MARK: - Logo & Title (Staggered)
                        VStack(spacing: 16) {
                                Image("AppLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                                    .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
                            .scaleEffect(appearScale)
                            .opacity(appearOpacity)
                            .animation(.springy.delay(0.1), value: appearScale)
                            
                            VStack(spacing: 8) {
                                Text("PocketPilot")
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .foregroundStyle(.primary)
                                
                                Text("Track expenses effortlessly")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .offset(y: appearOpacity == 1 ? 0 : 20)
                            .opacity(appearOpacity)
                            .animation(.gentle.delay(0.2), value: appearOpacity)
                        }
                        
                        // MARK: - Login Form
                        VStack(spacing: 24) {
                            VStack(spacing: 16) {
                                CustomTextField(
                                    icon: "envelope.fill",
                                    placeholder: "Email",
                                    text: $email,
                                    keyboardType: .emailAddress
                                )
                                
                                CustomSecureField(
                                    icon: "lock.fill",
                                    placeholder: "Password",
                                    text: $password,
                                    showPassword: $showPassword
                                )
                            }
                            
                            Button {
                                navigateToForgotPassword = true
                            } label: {
                                Text("Forgot Password?")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            // Login Button
                            Button {
                                Task { await handleLogin() }
                            } label: {
                                HStack {
                                    if authManager.isLoading {
                                        ProgressView().tint(.white)
                                    } else {
                                        Text("Login")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(colors: [Color.blue, Color.blue.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                                )
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .disabled(authManager.isLoading || !isValidForm)
                            .opacity(isValidForm ? 1 : 0.6)
                            .scaleEffect(!isValidForm ? 0.98 : 1.0)
                            .animation(.springy, value: isValidForm)
                            
                            // Sign Up Divert
                            HStack {
                                Text("Don't have an account?")
                                    .foregroundStyle(.secondary)
                                
                                Button {
                                    navigateToSignUp = true
                                } label: {
                                    Text("Sign Up")
                                        .fontWeight(.bold)
                                        .foregroundStyle(.primary)
                                }
                            }
                            .font(.subheadline)
                            .padding(.top, 8)
                        }
                        .padding(24)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                        .overlay(
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(.white.opacity(0.1), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 30, x: 0, y: 20)
                        .padding(.horizontal, 20)
                        .offset(y: appearOpacity == 1 ? 0 : 40)
                        .opacity(appearOpacity)
                        .animation(.gentle.delay(0.3), value: appearOpacity)
                        
                        Spacer()
                    }
                }
            }
            .onAppear {
                appearScale = 1.0
                appearOpacity = 1.0
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

#Preview {
    LoginView()
}
