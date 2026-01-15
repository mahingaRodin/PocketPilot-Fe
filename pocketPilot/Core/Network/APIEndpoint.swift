//
//  APIEndpoint.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation
import Alamofire

enum APIEndpoint: Sendable {
    case login
    case signup
    case logout
    case refreshToken
    case me
    case updateProfile
    case changePassword
    case forgotPassword
    case resetPassword
    case getProfile
    case getCategories
    
    // Expense endpoints
    case getExpenses
    case getExpense(String)
    case createExpense
    case updateExpense(String)
    case deleteExpense(String)
    case getDashboard
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .signup:
            return "/auth/register"
        case .logout:
            return "/auth/logout"
        case .refreshToken:
            return "/auth/refresh"
        case .me:
            return "/auth/me"
        case .updateProfile:
            return "/user/profile"
        case .getProfile:
            return "/user/profile"
        case .getCategories:
            return "/expenses/categories"
        case .changePassword:
            return "/auth/change-password"
        case .forgotPassword:
            return "/auth/forgot-password"
        case .resetPassword:
            return "/auth/reset-password"
        case .getExpenses:
            return "/expenses"
        case .getExpense(let id):
            return "/expenses/\(id)"
        case .createExpense:
            return "/expenses"
        case .updateExpense(let id):
            return "/expenses/\(id)"
        case .deleteExpense(let id):
            return "/expenses/\(id)"
        case .getDashboard:
            return "/dashboard"
        }
    }
    
    var headers: HTTPHeaders? {
        var headers = HTTPHeaders()
        headers.add(.contentType("application/json"))
        return headers
    }
    
    var requiresAuth: Bool {
        switch self {
        case .login, .signup, .forgotPassword, .resetPassword, .refreshToken:
            return false
        default:
            return true
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .signup, .logout, .refreshToken, .forgotPassword, .resetPassword, .changePassword, .createExpense:
            return .post
        case .updateProfile, .updateExpense:
            return .put
        case .deleteExpense:
            return .delete
        default:
            return .get
        }
    }
}
