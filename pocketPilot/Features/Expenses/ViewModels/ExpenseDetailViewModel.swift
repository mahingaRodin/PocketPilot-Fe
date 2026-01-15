//
//  ExpenseDetailViewModel.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation
import Observation
import Alamofire

@MainActor
@Observable
class ExpenseDetailViewModel {
    var expense: Expense?
    var isLoading: Bool = false
    var errorMessage: String?
    
    private let apiClient = APIClient.shared
    private let expenseId: String
    
    init(expenseId: String) {
        self.expenseId = expenseId
    }
    
    func loadExpense() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let data = try await apiClient.requestData(.getExpense(expenseId))
            let decoder = JSONDecoder.api
            let response = try decoder.decode(MainActorAPIResponse<Expense>.self, from: data)
            
            if response.success, let result = response.data {
                self.expense = result
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
    
    func deleteExpense() async {
        guard let expense = expense else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let data = try await apiClient.requestData(
                .deleteExpense(expense.id),
                method: .delete
            )
            
            let decoder = JSONDecoder.api
            let response = try decoder.decode(MainActorAPIResponse<EmptyResponse>.self, from: data)
            
            if !response.success {
                if let error = response.error {
                    self.errorMessage = error.message
                } else {
                    self.errorMessage = "Failed to delete expense"
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
