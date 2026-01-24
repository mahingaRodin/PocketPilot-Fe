//
//  BudgetViewModel.swift
//  pocketPilot
//
//  Created by headie-one on 01/21/26.
//

import Foundation
import Observation
import Alamofire

@MainActor
@Observable
class BudgetViewModel {
    var budgets: [BudgetStatus] = []
    var summary: BudgetSummary?
    var alerts: [BudgetAlert] = []
    var isLoading = false
    var errorMessage: String?
    var showError = false
    
    private let apiClient = APIClient.shared
    
    func loadBudgetSummary() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let data = try await apiClient.requestData(.getBudgetSummary)
            let decoder = JSONDecoder.api
            
            var decodedSummary: BudgetSummary?
            
            // Try decoding wrapped in MainActorAPIResponse
            if let response = try? decoder.decode(MainActorAPIResponse<BudgetSummary>.self, from: data) {
                decodedSummary = response.data
            }
            // Try decoding direct BudgetSummary (flat)
            else if let directSummary = try? decoder.decode(BudgetSummary.self, from: data) {
                decodedSummary = directSummary
            }
            
            if let result = decodedSummary {
                summary = result
                budgets = result.budgets
                
                // Filter alerts to only include those for categories the user actually has budgets for
                let activeBudgetIds = Set(result.budgets.map { $0.budget.id })
                alerts = result.alerts.filter { activeBudgetIds.contains($0.budgetId) }
            } else {
                print("DEBUG: [Budget] Failed to decode budget summary")
                // For debugging, print raw response
                if let raw = String(data: data, encoding: .utf8) {
                    print("DEBUG: [Budget] Raw response: \(raw)")
                }
            }
        } catch {
            print("DEBUG: [Budget] Load summary error: \(error)")
            errorMessage = "Failed to load budget summary"
            showError = true
        }
        
        isLoading = false
    }
    
    func createBudget(category: String, amount: Double, period: String, alertThreshold: Double) async throws {
        isLoading = true
        errorMessage = nil
        
        let params: [String: Any] = [
            "category": category,
            "amount": amount,
            "period": period,
            "alertThreshold": alertThreshold
        ]
        
        do {
            let data = try await apiClient.requestData(
                .createBudget,
                method: .post,
                parameters: params
            )
            
            let decoder = JSONDecoder.api
            // Just verify we got a valid response (Budget)
            if (try? decoder.decode(MainActorAPIResponse<Budget>.self, from: data)) != nil ||
               (try? decoder.decode(Budget.self, from: data)) != nil {
                await loadBudgetSummary()
            }
        } catch {
            errorMessage = "Failed to create budget: \(error.localizedDescription)"
            showError = true
            throw error
        }
        
        isLoading = false
    }
    
    func updateBudget(budgetId: UUID, amount: Double?, alertThreshold: Double?) async throws {
        isLoading = true
        errorMessage = nil
        
        var params: [String: Any] = [:]
        if let amount = amount { params["amount"] = amount }
        if let threshold = alertThreshold { params["alertThreshold"] = threshold }
        
        do {
            let data = try await apiClient.requestData(
                .updateBudget(budgetId.uuidString),
                method: .put,
                parameters: params
            )
            
            let decoder = JSONDecoder.api
            if (try? decoder.decode(MainActorAPIResponse<Budget>.self, from: data)) != nil ||
               (try? decoder.decode(Budget.self, from: data)) != nil {
                await loadBudgetSummary()
            }
        } catch {
            errorMessage = "Failed to update budget: \(error.localizedDescription)"
            showError = true
            throw error
        }
        
        isLoading = false
    }
    
    func deleteBudget(budgetId: UUID) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await apiClient.requestData(
                .deleteBudget(budgetId.uuidString),
                method: .delete
            )
            await loadBudgetSummary()
        } catch {
            errorMessage = "Failed to delete budget: \(error.localizedDescription)"
            showError = true
            throw error
        }
        
        isLoading = false
    }
    
    func markAlertAsRead(alertId: UUID) async throws {
        do {
            _ = try await apiClient.requestData(
                .markAlertRead(alertId.uuidString),
                method: .put
            )
            
            // Update local state
            if let index = alerts.firstIndex(where: { $0.id == alertId }) {
                let updatedAlert = alerts[index]
                alerts[index] = BudgetAlert(
                    id: updatedAlert.id,
                    budgetId: updatedAlert.budgetId,
                    alertType: updatedAlert.alertType,
                    thresholdPercentage: updatedAlert.thresholdPercentage,
                    triggeredAt: updatedAlert.triggeredAt,
                    isRead: true,
                    message: updatedAlert.message
                )
            }
        } catch {
            print("DEBUG: [Budget] Failed to mark alert as read: \(error)")
        }
    }
    
    func checkThresholds() async {
        // Refresh summary to get latest spending vs limit
        await loadBudgetSummary()
        
        // Trigger backend logic to generate notifications if any threshold is exceeded
        // NOTE: Commented out to prevent junk "Food" alerts when categories don't match
        // _ = try? await apiClient.requestData(.testBudgetAlert, method: .post)
        
        // Final refresh to see the new alerts in UI if any
        await loadBudgetSummary()
        
        // Update notification badge
        await NotificationManager.shared.fetchUnreadCount()
    }
}
