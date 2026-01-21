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
    case getProfilePicture(String)
    
    // Budget endpoints
    case getBudgets
    case createBudget
    case getBudgetSummary
    case getBudgetAlerts
    case markAlertRead(String)
    case updateBudget(String)
    case deleteBudget(String)
    
    // Notification endpoints
    case getNotifications
    case getUnreadNotificationCount
    case updateNotificationPreferences
    case markNotificationRead(String)
    case markAllNotificationsRead
    case registerPushToken
    case testBudgetAlert
    case testDailySummary
    
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
        case .uploadProfilePicture(let id), .updateProfilePicture(let id), .getProfilePicture(let id):
            return "/user/profile-picture/\(id)"
        case .deleteProfilePicture(let id):
            return "/user/profile-picture/\(id)"
        case .getBudgets, .createBudget:
            return "/budgets"
        case .getBudgetSummary:
            return "/budgets/summary"
        case .getBudgetAlerts:
            return "/budgets/alerts"
        case .markAlertRead(let id):
            return "/budgets/alerts/\(id)/read"
        case .updateBudget(let id), .deleteBudget(let id):
            return "/budgets/\(id)"
        case .getNotifications:
            return "/notifications"
        case .getUnreadNotificationCount:
            return "/notifications/unread/count"
        case .updateNotificationPreferences:
            return "/notifications/preferences"
        case .markNotificationRead(let id):
            return "/notifications/\(id)/read"
        case .markAllNotificationsRead:
            return "/notifications/read-all"
        case .registerPushToken:
            return "/notifications/register-push"
        case .testBudgetAlert:
            return "/notifications/test/budget-alert"
        case .testDailySummary:
            return "/notifications/test/daily-summary"
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
        case .login, .signup, .logout, .refreshToken, .forgotPassword, .resetPassword, .changePassword, .createExpense, .scanReceipt, .uploadReceipt, .generateReceipt, .uploadProfilePicture(_), .createBudget, .registerPushToken, .testBudgetAlert, .testDailySummary:
            return .post
        case .updateProfile, .updateExpense, .updateProfilePicture(_), .markAlertRead(_), .updateBudget(_), .updateNotificationPreferences, .markNotificationRead(_), .markAllNotificationsRead:
            return .put
        case .deleteExpense, .deleteProfilePicture(_), .deleteBudget(_):
            return .delete
        default:
            return .get
        }
    }
}
