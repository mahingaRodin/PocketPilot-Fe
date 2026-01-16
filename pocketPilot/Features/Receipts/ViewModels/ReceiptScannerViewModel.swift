
import Foundation
import UIKit
import Observation

@MainActor
@Observable
class ReceiptScannerViewModel {
    var selectedImage: UIImage?
    var isScanning: Bool = false
    var scanResult: ReceiptScanResult?
    var errorMessage: String?
    var showReviewScreen: Bool = false
    
    private let apiClient = APIClient.shared
    
    func scanReceipt() async {
        guard let image = selectedImage else {
            errorMessage = "No image selected"
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            errorMessage = "Failed to process image"
            return
        }
        
        isScanning = true
        errorMessage = nil
        
        do {
            let result: ReceiptScanResult = try await apiClient.upload(
                .scanReceipt,
                data: imageData,
                name: "file",
                fileName: "receipt.jpg",
                mimeType: "image/jpeg"
            )
            
            self.scanResult = result
            self.showReviewScreen = true
            
        } catch {
            print("Receipt scan failed: \(error)")
            errorMessage = "Could not analyze receipt. Please try again or enter details manually."
        }
        
        isScanning = false
    }
    
    func reset() {
        selectedImage = nil
        scanResult = nil
        errorMessage = nil
        showReviewScreen = false
        isScanning = false
    }
}
