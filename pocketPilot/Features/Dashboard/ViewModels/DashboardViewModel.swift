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
          
          if let response = try? decoder.decode(MainActorAPIResponse<[Expense]>.self, from: data), let result = response.data {
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
          
          // If we have data, try to plot it meaningfully
          if let firstDate = sortedKeys.first, let lastDate = sortedKeys.last {
              
              // Decide on a range. If data spans more than 30 days, show last 30.
              // If data is very sparse or old, just show the actual data points + intermediate zeros if the range isn't huge.
              // Better strategy for "Massive UI":
              // 1. If recent data (< 30 days old) exists, show last 30 days.
              // 2. If all data is old, show the range of the data itself.
              
              let now = Date()
              let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now) ?? now
              
              var startDate = firstDate
              var endDate = now
              
              // If we have recent activity, likely want to see that context
              if lastDate > thirtyDaysAgo {
                  startDate = thirtyDaysAgo
              } else {
                  // All data is old, just show the range of data
                  startDate = firstDate
                  endDate = lastDate
              }
              
              // Normalize start date to start of day
              startDate = calendar.startOfDay(for: startDate)
              endDate = calendar.startOfDay(for: endDate)
              
              var currentDate = startDate
              
              // Prevent infinite loops or massive ranges (cap at 60 days if range is huge)
              let daysDifference = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
              if daysDifference > 60 {
                   // If range is huge, just map the actual sorted keys to avoid looping thousands of days
                   chartData = sortedKeys.map { date in
                       let total = grouped[date]?.reduce(0) { $0 + $1.amount } ?? 0
                       return (date: date, amount: total)
                   }
              } else {
                  // Fill in the gaps
                  while currentDate <= endDate {
                       let dailyExpenses = grouped[currentDate] ?? []
                       let total = dailyExpenses.reduce(0) { $0 + $1.amount }
                       chartData.append((date: currentDate, amount: total))
                       
                       if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                           currentDate = nextDate
                       } else {
                           break
                       }
                  }
              }
          }
          
          self.trendData = chartData
          
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
