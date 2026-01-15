//
//  DashboardViewModel.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation
import Observation

@MainActor
@Observable
class DashboardViewModel {
    var dashboardData: DashboardData?
    var isLoading: Bool = false
    var errorMessage: String?
    
    private let apiClient = APIClient.shared
    
    func loadDashboard() async {
    isLoading = true
    errorMessage = nil

    do {
      let data = try await apiClient.requestData(.getDashboard)
      
      let decoder = JSONDecoder.api
      
      var decodedData: DashboardData?
      
      // Try 1: Actual Backend Response (Flat)
      if let backendResponse = try? decoder.decode(BackendDashboardResponse.self, from: data) {
          print("DEBUG: [Dashboard] Decoded using BackendDashboardResponse strategy")
          decodedData = backendResponse.toDashboardData()
      }
      // Try 2: Wrapped in MainActorAPIResponse
      else if let apiResponse = try? decoder.decode(MainActorAPIResponse<DashboardData>.self, from: data) {
          print("DEBUG: [Dashboard] Decoded using wrapped strategy")
          decodedData = apiResponse.data
      }
      // Try 3: Direct DashboardData
      else if let directData = try? decoder.decode(DashboardData.self, from: data) {
          print("DEBUG: [Dashboard] Decoded using direct DashboardData strategy")
          decodedData = directData
      }
      
      if let decodedData = decodedData {
          self.dashboardData = decodedData
      } else {
          print("DEBUG: [Dashboard] All decoding strategies failed")
          // Get the specific error for Try 1 to help debugging
          do {
              _ = try decoder.decode(BackendDashboardResponse.self, from: data)
          } catch {
              print("DEBUG: [Dashboard] Primary strategy error: \(error)")
          }
          self.dashboardData = .empty
      }
      
    } catch {
      print("DEBUG: Dashboard request failed: \(error.localizedDescription)")
      self.dashboardData = .empty
    }
    
    isLoading = false

    isLoading = false
  }

  func formatCurrency(_ amount: Double, currency: String = "USD") -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currency
    return formatter.string(from: NSNumber(value: amount)) ?? "\(currency) \(amount)"
  }
}
