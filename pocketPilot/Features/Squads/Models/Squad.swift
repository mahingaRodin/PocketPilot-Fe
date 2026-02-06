import Foundation

struct Squad: Codable, Identifiable, Sendable {
    let id: String
    let name: String?
    let description: String?
    let inviteCode: String?
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, inviteCode, createdAt
        case invite_code, created_at, squad_name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle id as either String or UUID, defaulting to a random one if missing
        if let idString = try? container.decode(String.self, forKey: .id) {
            id = idString
        } else if let idUUID = try? container.decode(UUID.self, forKey: .id) {
            id = idUUID.uuidString
        } else {
            // If ID is missing, we use a placeholder or let it fail? 
            // Better to let it fail or use a random one to see the rest of the data.
            id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        }
        
        name = (try? container.decodeIfPresent(String.self, forKey: .name))
            ?? (try? container.decodeIfPresent(String.self, forKey: .squad_name))
            ?? "Unnamed Squad"
            
        description = try? container.decodeIfPresent(String.self, forKey: .description)
        inviteCode = (try? container.decodeIfPresent(String.self, forKey: .inviteCode))
            ?? (try? container.decodeIfPresent(String.self, forKey: .invite_code))
        
        // Robust date decoding
        if let dateString = try? container.decodeIfPresent(String.self, forKey: .createdAt) ?? container.decodeIfPresent(String.self, forKey: .created_at) {
            let formatter = ISO8601DateFormatter()
            let formatterWithFractional = ISO8601DateFormatter()
            formatterWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            createdAt = formatter.date(from: dateString) ?? formatterWithFractional.date(from: dateString)
        } else {
            createdAt = nil
        }
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
