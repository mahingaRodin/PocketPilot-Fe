//
//  NotificationManager.swift
//  pocketPilot
//
//  Created by headie-one on 01/21/26.
//

import Foundation
import Observation

@MainActor
@Observable
class NotificationManager {
    static let shared = NotificationManager()
    
    var unreadCount: Int = 0
    var selectedTab: Int = 0
    
    private let apiClient = APIClient.shared
    
    private init() {}
    
    func fetchUnreadCount() async {
        do {
            let data = try await apiClient.requestData(.getUnreadNotificationCount)
            let decoder = JSONDecoder.api
            
            if let response = try? decoder.decode(MainActorAPIResponse<UnreadCountResponse>.self, from: data), let result = response.data {
                unreadCount = result.count
            } else if let result = try? decoder.decode(UnreadCountResponse.self, from: data) {
                unreadCount = result.count
            }
        } catch {
            print("DEBUG: [NotificationManager] Failed to fetch unread count: \(error)")
        }
    }
    
    func handleNavigation(for type: String) {
        switch type {
        case "budget_alert":
            selectedTab = 2 // Budget Tab
        case "daily_summary", "unusual_spending":
            selectedTab = 0 // Dashboard Tab
        default:
            break
        }
    }
}
