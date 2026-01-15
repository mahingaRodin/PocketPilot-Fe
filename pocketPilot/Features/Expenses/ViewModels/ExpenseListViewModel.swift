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
        
        do {
            let data = try await apiClient.requestData(.getExpenses)
            let decoder = JSONDecoder.api
            let response = try decoder.decode(MainActorAPIResponse<MainActorPaginatedResponse<Expense>>.self, from: data)
            
            if response.success, let result = response.data {
                expenses = result.data
                applyFilters()
            } else if let error = response.error {
                errorMessage = error.message
            } else {
                errorMessage = "Unknown error occurred"
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deleteExpense(_ expense: Expense) async {
        do {
            let data = try await apiClient.requestData(
                .deleteExpense(expense.id),
                method: .delete
            )
            
            let decoder = JSONDecoder.api
            let response = try decoder.decode(MainActorAPIResponse<EmptyResponse>.self, from: data)
            
            if response.success {
                await loadExpenses()
            } else if let error = response.error {
                errorMessage = error.message
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