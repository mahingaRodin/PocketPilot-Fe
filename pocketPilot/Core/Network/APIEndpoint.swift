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
    
    // Receipt endpoints
    case scanReceipt
    case uploadReceipt
    case generateReceipt(String)
    case viewReceipt(String)
    
    // Profile picture endpoints
    case uploadProfilePicture(String)
    case updateProfilePicture(String)
    case deleteProfilePicture(String)
    
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
        case .scanReceipt:
            return "/receipts/scan"
        case .uploadReceipt:
            return "/receipts/upload"
        case .generateReceipt(let id):
            return "/receipts/generate/\(id)"
        case .viewReceipt(let id):
            return "/receipts/\(id)/view"
        case .uploadProfilePicture(let id), .updateProfilePicture(let id):
            return "/user/profile-picture/\(id)"
        case .deleteProfilePicture(let id):
            return "/user/profile-picture/\(id)"
        }
    }
    
    var headers: HTTPHeaders? {
        var headers = HTTPHeaders()
        
        switch self {
        case .scanReceipt, .uploadReceipt, .uploadProfilePicture(_), .updateProfilePicture(_):
            // For multipart uploads, don't set Content-Type header. 
            // Alamofire will set it automatically with the correct boundary.
            break
        default:
            headers.add(.contentType("application/json"))
        }
        
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
        case .login, .signup, .logout, .refreshToken, .forgotPassword, .resetPassword, .changePassword, .createExpense, .scanReceipt, .uploadReceipt, .generateReceipt, .uploadProfilePicture(_):
            return .post
        case .updateProfile, .updateExpense, .updateProfilePicture(_):
            return .put
        case .deleteExpense, .deleteProfilePicture(_):
            return .delete
        default:
            return .get
        }
    }
}
