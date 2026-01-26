import Foundation

struct ChatMessage: Codable, Identifiable {
    let id: UUID
    let message: String
    let response: String
    let intent: String
    let timestamp: Date
    
    var isUser: Bool { true }
}

struct ChatResponse: Codable {
    let message: String
    let response: String
    let intent: String
    let contextData: ChatContextData?
    let timestamp: Date
}

struct ChatContextData: Codable {
    let amount: Double?
    let category: String?
    let timeframe: String?
    let comparison: String?
    let suggestions: [String]?
}
