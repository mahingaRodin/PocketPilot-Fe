import Foundation
import Alamofire

final class RequestInterceptor: Alamofire.RequestInterceptor, @unchecked Sendable {
    private let keychainManager = KeychainManager.shared
    private let lock = NSLock()
    private var isRefreshing = false
    private var requestsToRetry: [(RetryResult) -> Void] = []
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        
        // Don't add auth header to authentication endpoints
        if let path = urlRequest.url?.path {
            if path.contains("/auth/login") || 
               path.contains("/auth/register") || 
               path.contains("/auth/refresh") ||
               path.contains("/auth/forgot-password") ||
               path.contains("/auth/reset-password") {
                print("DEBUG: Skipping token adaptation for auth endpoint: \(path)")
                completion(.success(urlRequest))
                return
            }
        }
        
        if let token = keychainManager.getAccessToken() {
            let prefix = String(token.prefix(10))
            print("DEBUG: [Adapt] Request to \(urlRequest.url?.path ?? "unknown") with token: \(prefix)...")
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("DEBUG: No token found for request to \(urlRequest.url?.path ?? "unknown")")
        }
        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        
        // Prevent infinite loops
        if request.retryCount >= 3 {
            print("DEBUG: Max retries (3) reached for \(request.request?.url?.path ?? "unknown"). Stopping.")
            completion(.doNotRetry)
            return
        }
        
        // Prevent retrying auth-related endpoints to avoid infinite loops
        if let path = request.request?.url?.path {
            if path.contains("/auth/logout") || 
               path.contains("/auth/refresh") ||
               path.contains("/auth/login") ||
               path.contains("/auth/register") {
                completion(.doNotRetry)
                return
            }
        }
        
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }
        
        requestsToRetry.append(completion)
        
        guard !isRefreshing else {
            return
        }
        
        isRefreshing = true
        
        Task.detached { [weak self] in
            guard let self = self else { return }
            
            do {
                try await self.refreshAccessToken(with: session)
                
                self.lock.lock()
                let retryRequests = self.requestsToRetry
                self.requestsToRetry.removeAll()
                self.isRefreshing = false
                self.lock.unlock()
                
                retryRequests.forEach { $0(.retry) }
            } catch {
                self.lock.lock()
                let retryRequests = self.requestsToRetry
                self.requestsToRetry.removeAll()
                self.isRefreshing = false
                self.lock.unlock()
                
                retryRequests.forEach { $0(.doNotRetryWithError(error)) }
                
                await MainActor.run {
                    AuthManager.shared.logout()
                }
            }
        }
    }
    
    private func refreshAccessToken(with session: Session) async throws {
        guard let refreshToken = keychainManager.getRefreshToken() else {
            throw APIError.unauthorized
        }
        
        let url = Constants.API.baseURL + "/auth/refresh"
        let parameters: Parameters = ["refreshToken": refreshToken]
        
        print("DEBUG: Attempting refresh with token: \(refreshToken.prefix(10))...")
        let data = try await APIClient.shared.refreshRequest(url: url, parameters: parameters)
        
        do {
            let decoder = JSONDecoder.api
            
            // Define inline response wrapper to handle both wrapped and flat responses
            struct RefreshResponse: Codable {
                let success: Bool?
                let data: AuthResponse? // Wrapped version
                let accessToken: String? // Flat version
                let refreshToken: String? // Flat version
                let user: User?
                let expiresIn: Int?
            }
            
            let apiResponse = try decoder.decode(RefreshResponse.self, from: data)
            
            let authResponse: AuthResponse?
            
            if let wrappedData = apiResponse.data {
                authResponse = wrappedData
            } else if let access = apiResponse.accessToken, let refresh = apiResponse.refreshToken {
                authResponse = AuthResponse(
                    accessToken: access,
                    refreshToken: refresh,
                    user: apiResponse.user,
                    expiresIn: apiResponse.expiresIn
                )
            } else {
                authResponse = nil
            }
            
            if let finalAuth = authResponse, !finalAuth.accessToken.isEmpty {
                print("DEBUG: Successfully extracted new access token: \(finalAuth.accessToken.prefix(10))...")
                try keychainManager.saveTokens(
                    accessToken: finalAuth.accessToken,
                    refreshToken: finalAuth.refreshToken
                )
                
                // Final verification
                if let saved = keychainManager.getAccessToken(), saved == finalAuth.accessToken {
                    print("DEBUG: Token refreshed and verified in keychain.")
                } else {
                    print("DEBUG: CRITICAL - Refreshed token failed to persist!")
                    throw APIError.unknown("Keychain persistence failure")
                }
            } else {
                let body = String(data: data, encoding: .utf8) ?? "binary"
                print("DEBUG: Refresh failed - could not extract tokens from response structure. Body: \(body)")
                throw APIError.unauthorized
            }
        } catch {
            print("DEBUG: Refresh error: \(error)")
            throw error
        }
    }
}
