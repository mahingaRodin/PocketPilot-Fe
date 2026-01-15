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
      let response = try decoder.decode(MainActorAPIResponse<DashboardData>.self, from: data)
      
      if response.success, let result = response.data {
          self.dashboardData = result
      } else if let error = response.error {
          self.errorMessage = error.message
      } else {
          self.errorMessage = "Unknown error occurred"
      }
    } catch {
      errorMessage = error.localizedDescription
    }

    isLoading = false
  }

  func formatCurrency(_ amount: Double, currency: String = "USD") -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currency
    return formatter.string(from: NSNumber(value: amount)) ?? "\(currency) \(amount)"
  }
}
