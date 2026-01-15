//
//  APIError.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation

enum APIError: Error, LocalizedError, Sendable {
    case invalidURL
    case networkError(String)
    case decodingError(String)
    case unauthorized
    case forbidden
    case notFound
    case serverError(Int, String)
    case validationError([String: String])
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let message):
            return "Network error: \(message)"
        case .decodingError(let message):
            return "Data parsing error: \(message)"
        case .unauthorized:
            return "You need to login to continue"
        case .forbidden:
            return "You don't have permission to perform this action"
        case .notFound:
            return "Resource not found"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        case .validationError(let errors):
            return errors.values.first ?? "Validation error"
        case .unknown(let message):
            return message
        }
    }
}
