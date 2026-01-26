import Foundation
import Observation
import Alamofire

@Observable
class ChatViewModel {
    var messages: [ChatBubble] = []
    var isLoading = false
    var errorMessage: String?
    
    private let apiClient = APIClient.shared
    
    init() {
        // Add welcome message
        messages.append(ChatBubble(
            id: UUID(),
            text: "Hi! I'm your AI financial assistant. Ask me anything about your spending! 💰",
            isUser: false,
            timestamp: Date()
        ))
    }
    
    @MainActor
    func sendMessage(_ text: String) async {
        guard !text.isEmpty else { return }
        
        // Add user message
        let userBubble = ChatBubble(
            id: UUID(),
            text: text,
            isUser: true,
            timestamp: Date()
        )
        messages.append(userBubble)
        
        isLoading = true
        errorMessage = nil
        
        do {
            let parameters: [String: Any] = ["message": text]
            let data = try await apiClient.requestData(
                .chatAsk,
                method: .post,
                parameters: parameters
            )
            
            let decoder = JSONDecoder.api
            
            // Try wrapping response
            var chatData: ChatResponse?
            if let response = try? decoder.decode(MainActorAPIResponse<ChatResponse>.self, from: data) {
                 if response.success { chatData = response.data }
            } else {
                 chatData = try? decoder.decode(ChatResponse.self, from: data)
            }
            
            if let data = chatData {
                // Add AI response
                let aiBubble = ChatBubble(
                    id: UUID(),
                    text: data.response,
                    isUser: false,
                    timestamp: data.timestamp,
                    intent: data.intent
                )
                messages.append(aiBubble)
            } else {
                 throw APIError.decodingError("Failed to decode chat response")
            }
            
        } catch {
            print("DEBUG: [Chat] Error: \(error)")
            errorMessage = "Failed to get response. Please try again."
            
            // Add error message
            let errorBubble = ChatBubble(
                id: UUID(),
                text: "Sorry, I couldn't process that. Could you try rephrasing? 🤔",
                isUser: false,
                timestamp: Date()
            )
            messages.append(errorBubble)
        }
        
        isLoading = false
    }
    
    @MainActor
    func loadHistory() async {
        do {
            let data = try await apiClient.requestData(.chatHistory)
            let decoder = JSONDecoder.api
            
            var history: [ChatMessage]?
            if let response = try? decoder.decode(MainActorAPIResponse<[ChatMessage]>.self, from: data) {
                 if response.success { history = response.data }
            } else {
                 history = try? decoder.decode([ChatMessage].self, from: data)
            }
            
            if let history = history {
                // Clear and rebuild to avoid duplicates if needed, 
                // but usually we just want to show what's on server.
                messages.removeAll()
                // Re-add welcome if history is empty
                if history.isEmpty {
                     messages.append(ChatBubble(
                        id: UUID(),
                        text: "Hi! I'm your AI financial assistant. Ask me anything about your spending! 💰",
                        isUser: false,
                        timestamp: Date()
                    ))
                }
                
                // History often comes in reverse chronological or chronological. 
                // Assuming it might need reversing depending on backend implementation (linked list style vs array).
                // Let's assume it needs to be sorted by date.
                let sorted = history.sorted { $0.timestamp < $1.timestamp }
                
                for msg in sorted {
                    messages.append(ChatBubble(
                        id: msg.id,
                        text: msg.message,
                        isUser: true,
                        timestamp: msg.timestamp
                    ))
                    messages.append(ChatBubble(
                        id: UUID(),
                        text: msg.response,
                        isUser: false,
                        timestamp: msg.timestamp,
                        intent: msg.intent
                    ))
                }
            }
        } catch {
            print("Failed to load history: \(error)")
        }
    }
    
    @MainActor
    func clearHistory() async {
        do {
            let _ = try await apiClient.requestData(
                .chatClearHistory,
                method: .delete
            )
            
            messages.removeAll()
            
            // Add welcome message
            messages.append(ChatBubble(
                id: UUID(),
                text: "Hi! I'm your AI financial assistant. Ask me anything about your spending! 💰",
                isUser: false,
                timestamp: Date()
            ))
        } catch {
            errorMessage = "Failed to clear history"
        }
    }
}

// Chat Bubble Model
struct ChatBubble: Identifiable {
    let id: UUID
    let text: String
    let isUser: Bool
    let timestamp: Date
    let intent: String?
    
    init(id: UUID, text: String, isUser: Bool, timestamp: Date, intent: String? = nil) {
        self.id = id
        self.text = text
        self.isUser = isUser
        self.timestamp = timestamp
        self.intent = intent
    }
}
