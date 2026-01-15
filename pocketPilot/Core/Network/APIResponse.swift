struct APIResponse<T: Codable & Sendable>: Codable, Sendable {
    let success: Bool
    let data: T?
    let message: String?
    let error: APIErrorDetail?
}

struct APIErrorDetail: Codable, Sendable {
    let code: String
    let message: String
    let details: [String: String]?
}

struct PaginatedResponse<T: Codable & Sendable>: Codable, Sendable {
    let data: [T]
    let pagination: Pagination
}

struct Pagination: Codable, Sendable {
    let currentPage: Int
    let totalPages: Int
    let totalItems: Int
    let itemsPerPage: Int
}
