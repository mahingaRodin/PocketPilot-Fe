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
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.purple.opacity(0.6), .blue.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                        
                            .font(.system(size: 60))
                            .foregroundStyle(.white)
                        
                        Text("Create Account")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("Join PocketPilot today")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding(.top, 40)
                    
                    // Sign Up Form
                    VStack(spacing: 20) {
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
                            icon: "lock.fill",
                            placeholder: "Confirm Password",
                            text: $confirmPassword,
                            showPassword: $showConfirmPassword
                        )
                        
                        if !password.isEmpty && !confirmPassword.isEmpty {
                            PasswordStrengthView(password: password)
                        }
                        
                        // Terms and Conditions
                        HStack(spacing: 12) {
                            Button {
                                agreedToTerms.toggle()
                            } label: {
                                Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                            }
                            
                            Text("I agree to the Terms & Conditions")
                                .font(.footnote)
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Sign Up Button
                        Button {
                            Task {
                                await handleSignUp()
                            }
                        } label: {
                            if authManager.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Sign Up")
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
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
