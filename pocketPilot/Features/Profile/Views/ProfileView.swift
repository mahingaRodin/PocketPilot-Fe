//
//  ProfileView.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()
    @State private var showEditProfile = false
    @State private var showSettings = false
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        if let user = viewModel.currentUser {
                            // Profile Image
                            AsyncImage(url: URL(string: user.profileImageURL ?? "")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.blue, lineWidth: 3))
                            
                            Text(user.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(user.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } else {
                            ProgressView()
                        }
                    }
                    .padding(.top, 20)
                    
                    // Actions
                    VStack(spacing: 12) {
                        Button(action: { showEditProfile = true }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit Profile")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        Button(action: { showSettings = true }) {
                            HStack {
                                Image(systemName: "gearshape")
                                Text("Settings")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        Button(action: { showLogoutAlert = true }) {
                            HStack {
                                Image(systemName: "arrow.right.square")
                                Text("Logout")
                                Spacer()
                            }
                            .padding()
                            .foregroundColor(.red)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .alert("Logout", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    viewModel.logout()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
            .onAppear {
                viewModel.loadProfile()
            }
        }
    }
}

#Preview {
    ProfileView()
}
