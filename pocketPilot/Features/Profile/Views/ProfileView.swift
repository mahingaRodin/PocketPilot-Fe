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
    @State private var showImagePicker = false
    @State private var showPhotoOptions = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Profile Header Card
                        VStack(spacing: 20) {
                            if let user = viewModel.currentUser {
                                // Avatar Section with Edit Button
                                ZStack(alignment: .bottomTrailing) {
                                    ZStack {
                                        Circle()
                                            .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .frame(width: 100, height: 100)
                                            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                                        
                                        if let imageURL = user.profilePictureURL, !imageURL.isEmpty {
                                            // Construct full URL - backend returns relative path like /profile-pictures/uuid.jpg
                                            let baseURL = Constants.API.baseURL.replacingOccurrences(of: "/api/v1", with: "")
                                            let fullURLString = "\(baseURL)\(imageURL)"
                                            let _ = print("DEBUG: [ProfileView] Image URL: \(fullURLString)")
                                            
                                            if let fullURL = URL(string: fullURLString) {
                                                AsyncImage(url: fullURL) { phase in
                                                    switch phase {
                                                    case .success(let image):
                                                        image.resizable().aspectRatio(contentMode: .fill)
                                                    case .failure(let error):
                                                        VStack {
                                                            Image(systemName: "exclamationmark.triangle")
                                                            Text("Failed to load")
                                                                .font(.caption2)
                                                        }
                                                        .onAppear {
                                                            print("DEBUG: [ProfileView] Image load failed: \(error)")
                                                        }
                                                    case .empty:
                                                        ProgressView()
                                                    @unknown default:
                                                        ProgressView()
                                                    }
                                                }
                                                .frame(width: 100, height: 100)
                                                .clipShape(Circle())
                                            }
                                        } else {
                                            Text("\(user.firstName?.prefix(1) ?? "")\(user.lastName?.prefix(1) ?? "")")
                                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    
                                    // Edit Button
                                    Button {
                                        showPhotoOptions = true
                                    } label: {
                                        ZStack {
                                            Circle()
                                                .fill(Color.blue)
                                                .frame(width: 32, height: 32)
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(.white)
                                        }
                                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                    }
                                }
                                
                                VStack(spacing: 4) {
                                    Text(user.name)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Text(user.email ?? "")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                ProgressView()
                            }
                        }
                        .padding(.vertical, 32)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                        
                        // Menu Section
                        VStack(spacing: 16) {
                            menuButton(icon: "pencil", title: "Edit Profile", color: .blue) {
                                showEditProfile = true
                            }
                            
                            menuButton(icon: "gearshape.fill", title: "Settings", color: .gray) {
                                showSettings = true
                            }
                            
                            menuButton(icon: "rectangle.portrait.and.arrow.right.fill", title: "Logout", color: .red) {
                                showLogoutAlert = true
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
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
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: imageSourceType)
            }
            .onChange(of: selectedImage) { oldValue, newValue in
                if let image = newValue {
                    Task {
                        await viewModel.uploadProfilePicture(image)
                        selectedImage = nil
                    }
                }
            }
            .confirmationDialog("Profile Picture", isPresented: $showPhotoOptions, titleVisibility: .visible) {
                Button("Take Photo") {
                    imageSourceType = .camera
                    showImagePicker = true
                }
                Button("Choose from Library") {
                    imageSourceType = .photoLibrary
                    showImagePicker = true
                }
                if viewModel.currentUser?.profilePictureURL != nil {
                    Button("Remove Photo", role: .destructive) {
                        Task {
                            await viewModel.deleteProfilePicture()
                        }
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
    
    private func menuButton(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.subheadline)
                }
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    ProfileView()
}
