//
//  APIEndpoint.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation
import Alamofire

enum APIEndpoint {
    case login
    case signup
    case logout
    case refreshToken
    case me
    case updateProfile
    case changePassword
    case forgotPassword
    case resetPassword
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .signup:
            return "/auth/signup"
        case .logout:
            return "/auth/logout"
        case .refreshToken:
            return "/auth/refresh"
        case .me:
            return "/auth/me"
        case .updateProfile:
            return "/auth/profile"
        case .changePassword:
            return "/auth/change-password"
        case .forgotPassword:
            return "/auth/forgot-password"
        case .resetPassword:
            return "/auth/reset-password"
        }
    }
    
    var headers: HTTPHeaders? {
        var headers = HTTPHeaders()
        headers.add(.contentType("application/json"))
        
        // Add auth token for protected endpoints
        if requiresAuth {
            if let token = KeychainManager.shared.getAccessToken() {
                headers.add(.authorization(bearerToken: token))
            }
        }
        
        return headers
    }
    
    var requiresAuth: Bool {
        switch self {
        case .login, .signup, .forgotPassword, .resetPassword:
            return false
        default:
            return true
        }
    }
}
