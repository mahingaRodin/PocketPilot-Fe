//
//  NotificationViewModel.swift
//  pocketPilot
//
//  Created by headie-one on 01/21/26.
//

import Foundation
import Observation
import Alamofire

@MainActor
@Observable
class NotificationViewModel {
    var notifications: [Notification] = []
    var isLoading = false
    var errorMessage: String?
    var showError = false
    var successMessage: String?
    var showSuccess = false
    
    private let apiClient = APIClient.shared
    private let notificationManager = NotificationManager.shared
    
    var unreadCount: Int { notificationManager.unreadCount }
    var preferences: NotificationPreferences?
    
    func fetchNotifications(page: Int = 1, perPage: Int = 20) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let data = try await apiClient.requestData(
                .getNotifications,
                method: .get,
                parameters: ["page": page, "per": perPage],
                encoding: URLEncoding.default
            )
            
            // Debug logging
            if let raw = String(data: data, encoding: .utf8) {
                print("DEBUG: [Notifications] Raw response: \(raw)")
            }
            
            let decoder = JSONDecoder.api
            var decodedResponse: NotificationResponse?
            
            if let response = try? decoder.decode(MainActorAPIResponse<NotificationResponse>.self, from: data) {
                decodedResponse = response.data
            } else if let result = try? decoder.decode(NotificationResponse.self, from: data) {
                decodedResponse = result
            }
            
            if let result = decodedResponse {
                if page == 1 {
                    notifications = result.notifications
                } else {
                    notifications.append(contentsOf: result.notifications)
                }
            } else {
                print("DEBUG: [Notifications] Failed to decode notifications response")
            }
        } catch {
            print("DEBUG: [Notifications] Fetch error: \(error)")
            errorMessage = "Failed to load notifications"
            showError = true
        }
        
        isLoading = false
    }
    
    func fetchUnreadCount() async {
        await notificationManager.fetchUnreadCount()
    }
    
    func markAsRead(notificationId: UUID) async {
        do {
            _ = try await apiClient.requestData(
                .markNotificationRead(notificationId.uuidString),
                method: .put
            )
            
            if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
                let n = notifications[index]
                notifications[index] = Notification(
                    id: n.id,
                    type: n.type,
                    title: n.title,
                    message: n.message,
                    priority: n.priority,
                    isRead: true,
                    category: n.category,
                    createdAt: n.createdAt
                )
            }
            
            await fetchUnreadCount()
        } catch {
            print("DEBUG: [Notifications] Failed to mark as read: \(error)")
        }
    }
    
    func markAllAsRead() async {
        do {
            _ = try await apiClient.requestData(.markAllNotificationsRead, method: .put)
            
            // Update local state
            notifications = notifications.map { n in
                Notification(
                    id: n.id,
                    type: n.type,
                    title: n.title,
                    message: n.message,
                    priority: n.priority,
                    isRead: true,
                    category: n.category,
                    createdAt: n.createdAt
                )
            }
            
            await fetchUnreadCount()
        } catch {
            print("DEBUG: [Notifications] Failed to mark all as read: \(error)")
        }
    }
    
    func clearAll() {
        notifications = []
    }
    
    func navigate(for notification: Notification) {
        notificationManager.handleNavigation(for: notification.type)
    }
    
    func updatePreferences(_ prefs: NotificationPreferences) async {
        do {
            let params: [String: Any] = [
                "budgetAlertsEnabled": prefs.budgetAlertsEnabled,
                "quietHoursStart": prefs.quietHoursStart,
                "quietHoursEnd": prefs.quietHoursEnd,
                "pushEnabled": prefs.pushEnabled
            ]
            
            _ = try await apiClient.requestData(
                .updateNotificationPreferences,
                method: .put,
                parameters: params
            )
            
            self.preferences = prefs
            self.successMessage = "Preferences updated successfully"
            self.showSuccess = true
        } catch {
            errorMessage = "Failed to update preferences"
            showError = true
        }
    }
    
    func registerPushToken(_ token: String) async {
        do {
            _ = try await apiClient.requestData(
                .registerPushToken,
                method: .post,
                parameters: ["push_token": token]
            )
        } catch {
            print("DEBUG: [Notifications] Failed to register push token: \(error)")
        }
    }
    
    // Test endpoints
    func triggerTestBudgetAlert() async {
        isLoading = true
        do {
            _ = try await apiClient.requestData(.testBudgetAlert, method: .post)
            // Wait a moment for backend to process
            try? await Task.sleep(nanoseconds: 500_000_000)
            await fetchNotifications()
            await fetchUnreadCount()
        } catch {
            print("DEBUG: [Notifications] Test budget alert failed: \(error)")
            errorMessage = "Failed to trigger test alert"
            showError = true
        }
        isLoading = false
    }
    
    func triggerTestDailySummary() async {
        isLoading = true
        do {
            _ = try await apiClient.requestData(.testDailySummary, method: .post)
            // Wait a moment for backend to process
            try? await Task.sleep(nanoseconds: 500_000_000)
            await fetchNotifications()
            await fetchUnreadCount()
        } catch {
            print("DEBUG: [Notifications] Test daily summary failed: \(error)")
            errorMessage = "Failed to trigger test summary"
            showError = true
        }
        isLoading = false
    }
}
