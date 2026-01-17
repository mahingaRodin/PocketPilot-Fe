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
  
  var trendData: [(date: Date, amount: Double)] = []
  
  func loadTrendData() async {
      do {
          // Fetch last 30 days or all expenses?
          // Using getExpenses endpoint which supports filtering/pagination if needed, but for now let's try getting recent list.
          // Ideally we need a dedicated endpoint for historical data, but let's re-use getExpenses
          // with a date range if possible, or just grab a reasonable number.
          // Since getExpenses API might be paginated, let's assume we can get enough for a chart.
          // Wait, 'getExpenses' usually returns a list.
          
          let data = try await apiClient.requestData(.getExpenses)
          let decoder = JSONDecoder.api
          
          var expenses: [Expense] = []
          
          // Try to decode as BackendExpenseResponse (the structure seen in logs)
          if let backendResponse = try? decoder.decode(BackendExpenseResponse.self, from: data) {
              expenses = backendResponse.expenses
              print("DEBUG: [Trend] Decoded using BackendExpenseResponse. Found \(expenses.count) expenses.")
          }
           // Fallback decoding strategies
          else if let response = try? decoder.decode(MainActorAPIResponse<[Expense]>.self, from: data), let result = response.data {
              expenses = result
          } else if let result = try? decoder.decode([Expense].self, from: data) {
              expenses = result
          }
          
          // Group by day
          let calendar = Calendar.current
          let grouped = Dictionary(grouping: expenses) { expense in
              calendar.startOfDay(for: expense.date)
          }
          
          let sortedKeys = grouped.keys.sorted()
          
          var chartData: [(date: Date, amount: Double)] = []
          
          if let firstDate = sortedKeys.first, let lastDate = sortedKeys.last {
              // Always try to show the full range of data available, with a reasonable cap
               // If range is massive (> 90 days), just show the last 90 days of ACTUAL data (or summary)
               // But for now, let's just map the sorted keys to ensure NO data is hidden.
               
               // Fill gaps only if range is reasonable (< 60 days)
               let daysDifference = calendar.dateComponents([.day], from: firstDate, to: lastDate).day ?? 0
               
               if daysDifference <= 60 {
                   var currentDate = firstDate
                   while currentDate <= lastDate {
                       let dailyExpenses = grouped[currentDate] ?? []
                       let total = dailyExpenses.reduce(0) { $0 + $1.amount }
                       chartData.append((date: currentDate, amount: total))
                       
                       guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
                       currentDate = nextDate
                   }
               } else {
                   // Range is too big, just show the actual data points
                   chartData = sortedKeys.map { date in
                       let total = grouped[date]?.reduce(0) { $0 + $1.amount } ?? 0
                       return (date: date, amount: total)
                   }
                   // If we have massive gaps, this might look weird, but it's better than empty.
               }
          }
          
          // Verify we have data
          if chartData.isEmpty && !expenses.isEmpty {
               // Fallback: Just dump all expenses as points
               chartData = expenses.map { (date: $0.date, amount: $0.amount) }
               print("DEBUG: Trend fallback used.")
          }
          
          self.trendData = chartData
          print("DEBUG: Loaded \(chartData.count) trend points from \(expenses.count) expenses.")
          
      } catch {
          print("DEBUG: Failed to load trend data: \(error)")
      }
  }

  func formatCurrency(_ amount: Double, currency: String = "USD") -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currency
    return formatter.string(from: NSNumber(value: amount)) ?? "\(currency) \(amount)"
  }
}
