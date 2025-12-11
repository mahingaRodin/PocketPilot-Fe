//
//  APIClient.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//


import Foundation
import Alamofire

class APIClient {
    static let shared = APIClient()
    
    private let session: Session
    private let baseURL = Constants.API.baseURL
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Constants.API.timeout
        configuration.waitsForConnectivity = true
        
        let interceptor = RequestInterceptor()
        session = Session(
            configuration: configuration,
            interceptor: interceptor
        )
    }
    
    // Generic request method
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = JSONEncoding.default
    ) async throws -> T {
        let url = baseURL + endpoint.path
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(
                url,
                method: method,
                parameters: parameters,
                encoding: encoding,
                headers: endpoint.headers
            )
            .validate()
            .responseDecodable(of: APIResponse<T>.self) { response in
                switch response.result {
                case .success(let apiResponse):
                    if apiResponse.success, let data = apiResponse.data {
                        continuation.resume(returning: data)
                    } else {
                        let error = self.mapAPIError(apiResponse.error, statusCode: response.response?.statusCode)
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: self.handleAFError(error, response: response.response))
                }
            }
        }
    }
    
    // Upload method for images/files
    func upload<T: Decodable>(
        _ endpoint: APIEndpoint,
        data: Data,
        name: String,
        fileName: String,
        mimeType: String,
        parameters: Parameters? = nil
    ) async throws -> T {
        let url = baseURL + endpoint.path
        
        return try await withCheckedThrowingContinuation { continuation in
            session.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(
                        data,
                        withName: name,
                        fileName: fileName,
                        mimeType: mimeType
                    )
                    
                    if let parameters = parameters {
                        for (key, value) in parameters {
                            if let data = "\(value)".data(using: .utf8) {
                                multipartFormData.append(data, withName: key)
                            }
                        }
                    }
                },
                to: url,
                headers: endpoint.headers
            )
            .validate()
            .responseDecodable(of: APIResponse<T>.self) { response in
                switch response.result {
                case .success(let apiResponse):
                    if apiResponse.success, let data = apiResponse.data {
                        continuation.resume(returning: data)
                    } else {
                        let error = self.mapAPIError(apiResponse.error, statusCode: response.response?.statusCode)
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: self.handleAFError(error, response: response.response))
                }
            }
        }
    }
    
    private func handleAFError(_ error: AFError, response: HTTPURLResponse?) -> APIError {
        if let statusCode = response?.statusCode {
            switch statusCode {
            case 401:
                return .unauthorized
            case 403:
                return .forbidden
            case 404:
                return .notFound
            case 422:
                return .validationError([:])
            case 500...599:
                return .serverError(statusCode, "Server error occurred")
            default:
                break
            }
        }
        
        if let underlyingError = error.underlyingError as? URLError {
            switch underlyingError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .networkError("No internet connection")
            case .timedOut:
                return .networkError("Request timed out")
            default:
                return .networkError(underlyingError.localizedDescription)
            }
        }
        
        return .unknown(error.localizedDescription)
    }
    
    private func mapAPIError(_ error: APIErrorDetail?, statusCode: Int?) -> APIError {
        guard let error = error else {
            if let statusCode = statusCode {
                return .serverError(statusCode, "Unknown error")
            }
            return .unknown("Unknown error occurred")
        }
        
        if let details = error.details, !details.isEmpty {
            return .validationError(details)
        }
        
        switch statusCode {
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        default:
            return .serverError(statusCode ?? 0, error.message)
        }
    }
}

