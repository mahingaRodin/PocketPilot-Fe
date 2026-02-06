
import Foundation

@MainActor
struct MainActorAPIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let message: String?
    let error: APIErrorDetail?
}

