//
//  FileSharer.swift
//  pocketPilot
//
//  Created by headie-one on 01/21/26.
//

import SwiftUI
import UIKit

class FileSharer {
    static let shared = FileSharer()
    
    private init() {}
    
    func downloadAndShare(filename: String, endpoint: APIEndpoint) async {
        do {
            let data = try await APIClient.shared.requestData(endpoint)
            
            // Save to temporary file
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent(filename)
            
            try data.write(to: fileURL)
            
            // Present share sheet
            await MainActor.run {
                presentShareSheet(for: fileURL)
            }
        } catch {
            print("DEBUG: [FileSharer] Failed to download or share file: \(error)")
        }
    }
    
    private func presentShareSheet(for url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            
            // For iPad compatibility
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = rootVC.view
                popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            rootVC.present(activityVC, animated: true)
        }
    }
}
