
import Foundation

struct ReceiptItem: Codable, Identifiable, Sendable {
    var id: UUID = UUID()
    var name: String
    var quantity: Int
    var price: Double
    
    enum CodingKeys: String, CodingKey {
        case name, quantity, price
    }
    
    // Explicit init for usages
    init(id: UUID = UUID(), name: String, quantity: Int, price: Double) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.price = price
    }
    
    // Explicit Decodable
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        quantity = try container.decode(Int.self, forKey: .quantity)
        price = try container.decode(Double.self, forKey: .price)
        id = UUID() // Generate new ID on decode
    }
    
    // Explicit Encodable
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(price, forKey: .price)
    }
}

struct ReceiptScanResult: Codable, Sendable {
    let merchantName: String?
    let amount: Double?
    let date: Date?
    let suggestedCategory: String?
    let items: [ReceiptItem]?
    let confidence: Double
    let needsReview: Bool
    
    enum CodingKeys: String, CodingKey {
        case merchantName = "merchant_name"
        case amount
        case date
        case suggestedCategory = "suggested_category"
        case items
        case confidence
        case needsReview = "needs_review"
    }
    
    // Explicit init
    init(merchantName: String? = nil, amount: Double? = nil, date: Date? = nil, suggestedCategory: String? = nil, items: [ReceiptItem]? = nil, confidence: Double = 0.0, needsReview: Bool = false) {
        self.merchantName = merchantName
        self.amount = amount
        self.date = date
        self.suggestedCategory = suggestedCategory
        self.items = items
        self.confidence = confidence
        self.needsReview = needsReview
    }
    
    // Explicit Decodable
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        merchantName = try container.decodeIfPresent(String.self, forKey: .merchantName)
        amount = try container.decodeIfPresent(Double.self, forKey: .amount)
        
        // Handle Date decoding strategy manually if needed, or rely on decoder
        // APIClient uses .iso8601 or similar, let's assume standard decoding works with the container strategy
        date = try container.decodeIfPresent(Date.self, forKey: .date)
        
        suggestedCategory = try container.decodeIfPresent(String.self, forKey: .suggestedCategory)
        items = try container.decodeIfPresent([ReceiptItem].self, forKey: .items)
        confidence = try container.decodeIfPresent(Double.self, forKey: .confidence) ?? 0.0
        needsReview = try container.decodeIfPresent(Bool.self, forKey: .needsReview) ?? false
    }
    
    // Explicit Encodable
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(merchantName, forKey: .merchantName)
        try container.encodeIfPresent(amount, forKey: .amount)
        try container.encodeIfPresent(date, forKey: .date)
        try container.encodeIfPresent(suggestedCategory, forKey: .suggestedCategory)
        try container.encodeIfPresent(items, forKey: .items)
        try container.encode(confidence, forKey: .confidence)
        try container.encode(needsReview, forKey: .needsReview)
    }
}
