
import Foundation
import Alamofire

class RequestInterceptor: Alamofire.RequestInterceptor {
    
    private let keychainManager = KeychainManager.shared
    private let lock = NSLock()
    private var isRefreshing = false
    private var requestsToRetry: [(RetryResult) -> Void] = []
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        
        // Add access token if available
        if let token = keychainManager.getAccessToken() {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        
        // Only retry on 401 unauthorized
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }
        
        requestsToRetry.append(completion)
        
        // If already refreshing, just queue this request
        guard !isRefreshing else {
            return
        }
        
        isRefreshing = true
        
        // Attempt to refresh token
        Task {
            do {
                try await refreshAccessToken()
                
                lock.lock()
                let retryRequests = requestsToRetry
                requestsToRetry.removeAll()
                isRefreshing = false
                lock.unlock()
                
                // Retry all queued requests
                retryRequests.forEach { $0(.retry) }
            } catch {
                lock.lock()
                let retryRequests = requestsToRetry
                requestsToRetry.removeAll()
                isRefreshing = false
                lock.unlock()
                
                // Don't retry if refresh failed
                retryRequests.forEach { $0(.doNotRetryWithError(error)) }
                
                // Logout user
                await MainActor.run {
                    AuthManager.shared.logout()
                }
            }
        }
    }
    
    private func refreshAccessToken() async throws {
        guard let refreshToken = keychainManager.getRefreshToken() else {
            throw APIError.unauthorized
        }
        
        let parameters: Parameters = [
            "refresh_token": refreshToken
        ]
        
        let response: AuthResponse = try await APIClient.shared.request(
            .refreshToken,
            method: .post,
            parameters: parameters
        )
        
        try keychainManager.saveTokens(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken
        )
    }
}
