//
//  Notification.swift
//  pocketPilot
//
//  Created by headie-one on 01/21/26.
//

import Foundation

struct Notification: Codable, Identifiable, Sendable {
    let id: UUID
    let type: String
    let title: String
    let message: String
    let priority: String
    let isRead: Bool
    let category: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, type, title, message, priority, category
        case isRead = "is_read"
        case createdAt = "created_at"
    }
}

struct NotificationResponse: Codable, Sendable {
    let notifications: [Notification]
    let total: Int
    let page: Int
    let perPage: Int
}

struct UnreadCountResponse: Codable, Sendable {
    let count: Int
}

struct NotificationPreferences: Codable, Sendable {
    var budgetAlertsEnabled: Bool
    var quietHoursStart: Int
    var quietHoursEnd: Int
    var pushEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case budgetAlertsEnabled = "budget_alerts_enabled"
        case quietHoursStart = "quiet_hours_start"
        case quietHoursEnd = "quiet_hours_end"
        case pushEnabled = "push_enabled"
    }
}


