//
//  ExpenseListViewModel.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation
import Observation
import Alamofire

@MainActor
@Observable
class ExpenseListViewModel {
    var expenses: [Expense] = []
    var filteredExpenses: [Expense] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var selectedCategory: Category?
    var searchText: String = ""
    var selectedDateRange: DateRange = .all
    
    private let apiClient = APIClient.shared
    
    enum DateRange: String, CaseIterable {
        case all = "All Time"
        case today = "Today"
        case week = "This Week"
        case month = "This Month"
        case year = "This Year"
    }
    
    func loadExpenses() async {
        isLoading = true
        errorMessage = nil
        
        print("DEBUG: [Expenses] Starting to load expenses...")
        print("DEBUG: [Expenses] Access token exists: \(KeychainManager.shared.getAccessToken() != nil)")
        
        do {
            let data = try await apiClient.requestData(.getExpenses)
            
            // Log the raw response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("DEBUG: [Expenses] Raw API response: \(jsonString)")
            }
            
            let decoder = JSONDecoder.api
            
            // Try 1: Actual backend structure (Flat BackendExpenseResponse)
            if let response = try? decoder.decode(BackendExpenseResponse.self, from: data) {
                print("DEBUG: [Expenses] Decoded using BackendExpenseResponse strategy")
                expenses = response.expenses
            }
            // Try 2: Wrap in MainActorAPIResponse<MainActorPaginatedResponse<Expense>>
            else if let response = try? decoder.decode(MainActorAPIResponse<MainActorPaginatedResponse<Expense>>.self, from: data),
               response.success, let result = response.data {
                print("DEBUG: [Expenses] Decoded using wrapped paginated strategy")
                expenses = result.data
            }
            // Try 3: Wrap in MainActorAPIResponse<[Expense]>
            else if let response = try? decoder.decode(MainActorAPIResponse<[Expense]>.self, from: data),
                    response.success, let result = response.data {
                print("DEBUG: [Expenses] Decoded using wrapped array strategy")
                expenses = result
            }
            // Try 4: Flat array [Expense]
            else if let result = try? decoder.decode([Expense].self, from: data) {
                print("DEBUG: [Expenses] Decoded using flat array strategy")
                expenses = result
            }
            // Fallback: Try decoding to see if it's a specific error response
            else if let apiResponse = try? decoder.decode(MainActorAPIResponse<EmptyResponse>.self, from: data) {
                if !apiResponse.success, let error = apiResponse.error {
                    errorMessage = error.message
                    print("DEBUG: [Expenses] API returned error: \(error.message)")
                } else {
                    expenses = []
                    print("DEBUG: [Expenses] Decoded empty success response")
                }
            }
            else {
                print("DEBUG: [Expenses] All decoding strategies failed.")
                errorMessage = "Failed to parse expense data"
            }
            
            print("DEBUG: [Expenses] Total expenses loaded: \(expenses.count)")
            applyFilters()
        } catch {
            print("DEBUG: [Expenses] Exception caught: \(error)")
            print("DEBUG: [Expenses] Error type: \(type(of: error))")
            // Check if it's a permission error
            if let apiError = error as? APIError {
                switch apiError {
                case .forbidden:
                    errorMessage = "You don't have permission to view expenses"
                case .unauthorized:
                    errorMessage = "Please log in to view expenses"
                default:
                    errorMessage = error.localizedDescription
                }
            } else {
                errorMessage = error.localizedDescription
            }
        }
        
        isLoading = false
        print("DEBUG: [Expenses] Loading complete. Error: \(errorMessage ?? "none")")
    }
    
    func deleteExpense(_ expense: Expense) async {
        do {
            let data = try await apiClient.requestData(
                .deleteExpense(expense.id),
                method: .delete
            )
            
            let decoder = JSONDecoder.api
            
            // Flexible decoding
            let success: Bool
            if let wrapped = try? decoder.decode(MainActorAPIResponse<EmptyResponse>.self, from: data) {
                success = wrapped.success
            } else {
                // Assume success if no error was thrown by requestData (2xx)
                success = true
            }
            
            if success {
                await loadExpenses()
            } else {
                errorMessage = "Failed to delete expense"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func applyFilters() {
        filteredExpenses = expenses
        
        // Filter by category
        if let selectedCategory = selectedCategory {
            filteredExpenses = filteredExpenses.filter { $0.category.id == selectedCategory.id }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filteredExpenses = filteredExpenses.filter {
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.category.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by date range
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedDateRange {
        case .today:
            filteredExpenses = filteredExpenses.filter {
                calendar.isDateInToday($0.date)
            }
        case .week:
            filteredExpenses = filteredExpenses.filter {
                calendar.isDate($0.date, equalTo: now, toGranularity: .weekOfYear)
            }
        case .month:
            filteredExpenses = filteredExpenses.filter {
                calendar.isDate($0.date, equalTo: now, toGranularity: .month)
            }
        case .year:
            filteredExpenses = filteredExpenses.filter {
                calendar.isDate($0.date, equalTo: now, toGranularity: .year)
            }
        case .all:
            break
        }
        
        // Sort by date (newest first)
        filteredExpenses.sort { $0.date > $1.date }
    }
}