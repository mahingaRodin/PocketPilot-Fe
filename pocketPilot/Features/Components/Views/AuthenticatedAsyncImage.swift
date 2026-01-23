//
//  AuthenticatedAsyncImage.swift
//  pocketPilot
//
//  Created by Antigravity on 01/21/26.
//

import SwiftUI

struct AuthenticatedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    
    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var error: Error?
    
    init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else if isLoading {
                placeholder()
            } else if error != nil {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                    Text("Error")
                        .font(.caption2)
                }
            } else {
                placeholder()
            }
        }
        .onAppear {
            loadImage()
        }
        .onChange(of: url) { oldValue, newValue in
            if newValue != oldValue {
                self.image = nil
                loadImage()
            }
        }
    }
    
    private func loadImage() {
        guard let url = url, !isLoading else { return }
        if image != nil && url.absoluteString.contains("v=") == false { return } 
        
        isLoading = true
        error = nil
        
        var request = URLRequest(url: url)
        if let token = KeychainManager.shared.getAccessToken() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.error = error
                    return
                }
                
                guard let data = data, let uiImage = UIImage(data: data) else {
                    self.error = NSError(domain: "ImageLoading", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode image data"])
                    return
                }
                
                self.image = uiImage
            }
        }.resume()
    }
}
