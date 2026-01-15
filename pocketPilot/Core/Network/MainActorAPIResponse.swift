
import Foundation

@MainActor
struct MainActorAPIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let message: String?
    let error: APIErrorDetail?
}

@MainActor
struct MainActorPaginatedResponse<T: Decodable>: Decodable {
    let data: [T]
    let pagination: Pagination
}
