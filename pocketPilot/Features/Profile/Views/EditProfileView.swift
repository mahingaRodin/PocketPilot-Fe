//
//  EditProfileView.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var showSuccess: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    private let authManager = AuthManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(
                    colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Avatar Section
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 100, height: 100)
                                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                                
                                Text("\(firstName.prefix(1))\(lastName.prefix(1))")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            
                            Button(action: {
                                // Action for changing photo
                            }) {
                                Text("Change Photo")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.top, 40)
                        
                        // Form Section
                        VStack(alignment: .leading, spacing: 24) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Profile Details")
                                    .font(.headline)
                                    .padding(.leading, 4)
                                
                                VStack(spacing: 16) {
                                    CustomTextField(icon: "person.fill", placeholder: "First Name", text: $firstName)
                                    CustomTextField(icon: "person.fill", placeholder: "Last Name", text: $lastName)
                                }
                            }
                            
                            if let error = errorMessage {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Save Button
                        Button(action: {
                            Task {
                                await saveProfile()
                            }
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                        .padding(.trailing, 8)
                                }
                                Text("Save Changes")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .disabled(isLoading || firstName.isEmpty || lastName.isEmpty)
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        Spacer()
                    }
                    .padding(.bottom, 32)
                }
                
                if showSuccess {
                    SuccessOverlayView(message: "Profile Updated!", isPresented: $showSuccess)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.gray)
                            .font(.title3)
                    }
                }
            }
            .onAppear {
                firstName = authManager.currentUser?.firstName ?? ""
                lastName = authManager.currentUser?.lastName ?? ""
            }
        }
    }
    
    private func saveProfile() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authManager.updateProfile(firstName: firstName, lastName: lastName, profileImage: nil)
            withAnimation { showSuccess = true }
            try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    EditProfileView()
}
