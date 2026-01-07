//
//  WebSocketManager.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation
import Combine

class WebSocketManager: ObservableObject {
    static let shared = WebSocketManager()
    
    @Published var isConnected: Bool = false
    @Published var lastMessage: WebSocketMessage?
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let url: URL
    
    private init() {
        self.url = URL(string: Constants.API.webSocketURL)!
    }
    
    func connect() {
        guard let token = KeychainManager.shared.getAccessToken() else {
            print("No access token available for WebSocket connection")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        
        isConnected = true
        receiveMessage()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.handleMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self?.handleMessage(text)
                    }
                @unknown default:
                    break
                }
                
                // Continue receiving messages
                self?.receiveMessage()
                
            case .failure(let error):
                print("WebSocket receive error: \(error)")
                self?.isConnected = false
            }
        }
    }
    
    private func handleMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let message = try? JSONDecoder().decode(WebSocketMessage.self, from: data) else {
            return
        }
        
        DispatchQueue.main.async {
            self.lastMessage = message
            // Handle message based on type
            self.processMessage(message)
        }
    }
    
    private func processMessage(_ message: WebSocketMessage) {
        switch message.type {
        case .expenseCreated, .expenseUpdated, .expenseDeleted:
            // Notify views to refresh
            NotificationCenter.default.post(
                name: NSNotification.Name("ExpenseUpdated"),
                object: nil
            )
        default:
            break
        }
    }
    
    func sendMessage(_ message: WebSocketMessage) {
        guard let data = try? JSONEncoder().encode(message),
              let text = String(data: data, encoding: .utf8) else {
            return
        }
        
        webSocketTask?.send(.string(text)) { error in
            if let error = error {
                print("WebSocket send error: \(error)")
            }
        }
    }
}