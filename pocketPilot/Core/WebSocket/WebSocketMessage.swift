//
//  WebSocketMessage.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

struct WebSocketMessage: Codable {
    let type: MessageType, 
    let payload: MessagePayload,
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
    case team(Team)
    case member(TeamMember)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let expense = try? container.decode(Expense.self) {
            self = .expense(expense)
        } else if let team = try? container.decode(Team.self) {
            self = .team(team)
        } else if let member = try? container.decode(TeamMember.self) {
            self = .member(member)
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
        case .team(let team):
            try container.encode(team)
        case .member(let member):
            try container.encode(member)
        }
    }
}
