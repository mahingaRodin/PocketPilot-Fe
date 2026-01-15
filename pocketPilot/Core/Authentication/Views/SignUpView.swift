import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var showError = false
    @State private var agreedToTerms = false
    
    // Animation States
    @State private var isAnimating = false
    @State private var appearScale = 0.8
    @State private var appearOpacity = 0.0
    
    var body: some View {
        ZStack {
            // MARK: - Animated Immersive Background
            ZStack {
                Color.black.ignoresSafeArea()
                
                // Dancing Blur 1
                Circle()
                    .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 450, height: 450)
                    .blur(radius: 90)
                    .offset(x: isAnimating ? 100 : -100, y: isAnimating ? 150 : -150)
                    .opacity(0.5)
                
                // Dancing Blur 2
                Circle()
                    .fill(LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 350, height: 350)
                    .blur(radius: 70)
                    .offset(x: isAnimating ? -150 : 150, y: isAnimating ? -100 : 100)
                    .opacity(0.4)
            }
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(colors: [.white, .white.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                            )
                            .shadow(color: .purple.opacity(0.5), radius: 15, x: 0, y: 8)
                            .scaleEffect(appearScale)
                            .opacity(appearOpacity)
                            .animation(.springy.delay(0.1), value: appearScale)
                        
                        VStack(spacing: 8) {
                            Text("Create Account")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            
                            Text("Join PocketPilot today")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .offset(y: appearOpacity == 1 ? 0 : 20)
                        .opacity(appearOpacity)
                        .animation(.gentle.delay(0.2), value: appearOpacity)
                    }
                    .padding(.top, 40)
                    
                    // MARK: - Sign Up Form
                    VStack(spacing: 20) {
                        HStack(spacing: 16) {
                            CustomTextField(
                                icon: "person.fill",
                                placeholder: "First Name",
                                text: $firstName
                            )
                            
                            CustomTextField(
                                icon: "person.fill",
                                placeholder: "Last Name",
                                text: $lastName
                            )
                        }
                        
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
                        
                        CustomSecureField(
                            icon: "lock.rectangle.fill",
                            placeholder: "Confirm Password",
                            text: $confirmPassword,
                            showPassword: $showConfirmPassword
                        )
                        
                        if !password.isEmpty {
                            PasswordStrengthView(password: password)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        
                        // Terms and Conditions
                        Button {
                            withAnimation(.springy) {
                                agreedToTerms.toggle()
                            }
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(.white.opacity(0.5), lineWidth: 1.5)
                                        .frame(width: 22, height: 22)
                                    
                                    if agreedToTerms {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(.white)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(Color.blue)
                                                    .frame(width: 22, height: 22)
                                            )
                                    }
                                }
                                
                                Text("I agree to the Terms & Conditions")
                                    .font(.footnote)
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                        
                        // Sign Up Button
                        Button {
                            Task { await handleSignUp() }
                        } label: {
                            HStack {
                                if authManager.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Create Account")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .disabled(authManager.isLoading || !isValidForm)
                        .opacity(isValidForm ? 1 : 0.6)
                        .scaleEffect(isValidForm ? 1.0 : 0.98)
                        .animation(.springy, value: isValidForm)
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
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            appearScale = 1.0
            appearOpacity = 1.0
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                }
            }
        }
        .alert("Sign Up Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(authManager.errorMessage ?? "An error occurred")
        }
    }
    
    private var isValidForm: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        email.contains("@") &&
        password.count >= 8 &&
        password == confirmPassword &&
        agreedToTerms
    }
    
    private func handleSignUp() async {
        do {
            try await authManager.signUp(
                email: email,
                password: password,
                firstName: firstName,
                lastName: lastName,
                confirmPassword: confirmPassword
            )
        } catch {
            showError = true
        }
    }
}

#Preview {
    SignUpView()
}
