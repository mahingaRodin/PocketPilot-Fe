//
//  ExpenseDetailViewModel.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation
import Observation

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
            expense = try await apiClient.request(.getExpense(expenseId))
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
            let _: EmptyResponse = try await apiClient.request(
                .deleteExpense(expense.id),
                method: .delete
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}