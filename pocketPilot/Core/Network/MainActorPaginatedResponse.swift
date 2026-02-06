import Foundation

struct PaginatedAPIResponse<T: Decodable>: Decodable {
    let data: [T]
    let metadata: PaginationMetadata?
    let message: String?
    let error: APIErrorDetail?
    let success: Bool
    
    enum CodingKeys: String, CodingKey {
        case data
        case metadata
        case message
        case error
        case success
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle data being nil or empty
        if let data = try? container.decode([T].self, forKey: .data) {
            self.data = data
        } else {
            self.data = []
        }
        
        self.metadata = try? container.decodeIfPresent(PaginationMetadata.self, forKey: .metadata)
        self.message = try? container.decodeIfPresent(String.self, forKey: .message)
        self.error = try? container.decodeIfPresent(APIErrorDetail.self, forKey: .error)
        self.success = (try? container.decodeIfPresent(Bool.self, forKey: .success)) ?? (error == nil)
    }
}

struct PaginationMetadata: Decodable, Sendable {
    let page: Int
    let per: Int
    let total: Int
}

extension PaginatedAPIResponse: Sendable where T: Sendable {}
