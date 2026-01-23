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
        
        if let topVC = getTopViewController() {
            // For iPad compatibility
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = topVC.view
                popover.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            topVC.present(activityVC, animated: true)
        }
    }
    
    private func getTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first else {
            return nil
        }
        
        var topVC = window.rootViewController
        while let presentedVC = topVC?.presentedViewController {
            topVC = presentedVC
        }
        return topVC
    }
}
