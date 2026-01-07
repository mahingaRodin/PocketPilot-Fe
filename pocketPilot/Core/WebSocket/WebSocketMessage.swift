//
//  WebSocketMessage.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

struct WebSocketMessage: Codable {
    let type: MessageType
    let payload: MessagePayload
    let timestamp: Date
}

enum MessageType: String, Codable {
    case expenseCreated = "expense_created"
    case expenseUpdated = "expense_updated"
    case expenseDeleted = "expense_deleted"
    case teamUpdated = "team_updated"
    case memberJoined = "member_joined"
    case memberLeft = "member_left"
}

enum MessagePayload: Codable {
    case expense(Expense)
    case data([String: String])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let expense = try? container.decode(Expense.self) {
            self = .expense(expense)
        } else if let data = try? container.decode([String: String].self) {
            self = .data(data)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid payload type"
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .expense(let expense):
            try container.encode(expense)
        case .data(let data):
            try container.encode(data)
        }
    }
}
