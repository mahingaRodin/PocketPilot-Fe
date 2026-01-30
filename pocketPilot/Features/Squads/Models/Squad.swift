import Foundation

struct Squad: Codable, Identifiable, Sendable {
    let id: UUID
    let name: String
    let description: String?
    let inviteCode: String?
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, inviteCode, createdAt
        case invite_code, created_at
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        inviteCode = try container.decodeIfPresent(String.self, forKey: .inviteCode)
            ?? container.decodeIfPresent(String.self, forKey: .invite_code)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
            ?? container.decodeIfPresent(Date.self, forKey: .created_at)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(inviteCode, forKey: .inviteCode)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
    }
}

struct SquadSettlement: Codable, Sendable, Identifiable {
    var id: String { "\(fromUserID)-\(toUserID)-\(amount)" }
    let fromUserID: String
    let fromUserName: String
    let toUserID: String
    let toUserName: String
    let amount: Double
}

struct CreateSquadRequest: Encodable {
    let name: String
    let description: String?
}

struct JoinSquadRequest: Encodable {
    let inviteCode: String
}
