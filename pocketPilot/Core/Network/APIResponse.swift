struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let message: String?
    let error: APIErrorDetail?
}

struct APIErrorDetail: Codable {
    let code: String
    let message: String
    let details: [String: String]?
}

struct PaginatedResponse<T: Codable>: Codable {
    let data: [T]
    let pagination: Pagination
}

struct Pagination: Codable {
    let currentPage: Int
    let totalPages: Int
    let totalItems: Int
    let itemsPerPage: Int
    
    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case totalPages = "total_pages"
        case totalItems = "total_items"
        case itemsPerPage = "items_per_page"
    }
}
