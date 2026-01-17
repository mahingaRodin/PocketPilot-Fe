
import SwiftUI
import WebKit

struct ReceiptPreviewView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = true
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        var request = URLRequest(url: url)
        
        // Add authentication token if available
        if let token = KeychainManager.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        uiView.load(request)
    }
}
