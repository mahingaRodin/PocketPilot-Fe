
import SwiftUI

struct ReceiptScannerView: View {
    @State private var viewModel = ReceiptScannerViewModel()
    @Binding var isPresented: Bool
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    
    // Navigation to add expense
    @State private var navigateToAddExpense = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    Text("Scan Receipt")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Take a photo or upload from gallery to automatically extract details.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    if viewModel.isScanning {
                        VStack(spacing: 16) {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.5)
                            Text("Analyzing receipt...")
                                .foregroundColor(.white)
                        }
                    } else {
                        VStack(spacing: 16) {
                            Button {
                                sourceType = .camera
                                showImagePicker = true
                            } label: {
                                Label("Take Photo", systemImage: "camera.fill")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            
                            Button {
                                sourceType = .photoLibrary
                                showImagePicker = true
                            } label: {
                                Label("Choose from Gallery", systemImage: "photo.on.rectangle")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $viewModel.selectedImage, sourceType: sourceType)
            }
            .onChange(of: viewModel.selectedImage) { oldValue, newValue in
                if newValue != nil {
                    Task {
                        await viewModel.scanReceipt()
                    }
                }
            }
            .onChange(of: viewModel.showReviewScreen) { oldValue, newValue in
                if newValue {
                     navigateToAddExpense = true
                }
            }
            .navigationDestination(isPresented: $navigateToAddExpense) {
                AddExpenseView(prefilledResult: viewModel.scanResult, prefilledImage: viewModel.selectedImage)
            }
            .alert("Error", isPresented: Binding(get: { viewModel.errorMessage != nil }, set: { _ in viewModel.errorMessage = nil })) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
        }
    }
}
