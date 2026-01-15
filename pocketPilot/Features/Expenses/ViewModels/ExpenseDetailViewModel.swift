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
            
            // Log for debugging
            if let json = String(data: data, encoding: .utf8) {
                print("DEBUG: [Detail] Raw response: \(json)")
            }
            
            var decodedExpense: Expense?
            
            // Try 1: Wrapped Response
            do {
                let response = try decoder.decode(MainActorAPIResponse<Expense>.self, from: data)
                if response.success, let result = response.data {
                    decodedExpense = result
                }
            } catch {
                print("DEBUG: [Detail] Wrapped strategy failed: \(error)")
            }
            
            // Try 2: Flat Expense Object
            if decodedExpense == nil {
                do {
                    let result = try decoder.decode(Expense.self, from: data)
                    print("DEBUG: [Detail] Decoded using flat Expense strategy")
                    decodedExpense = result
                } catch {
                    print("DEBUG: [Detail] Flat strategy failed: \(error)")
                }
            }
            
            if let decodedExpense = decodedExpense {
                self.expense = decodedExpense
            } else {
                print("DEBUG: [Detail] All decoding strategies failed")
                self.errorMessage = "Failed to load expense details"
            }
        } catch {
            print("DEBUG: [Detail] Request failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateExpense(amount: Double, description: String, category: String, date: Date, notes: String?) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let formatter = ISO8601DateFormatter()
            let parameters: [String: Any] = [
                "amount": amount,
                "description": description,
                "category": category,
                "date": formatter.string(from: date),
                "notes": notes as Any
            ]
            
            let data = try await apiClient.requestData(
                .updateExpense(expenseId),
                method: .put,
                parameters: parameters
            )
            
            let decoder = JSONDecoder.api
            var decodedExpense: Expense?

            if let response = try? decoder.decode(MainActorAPIResponse<Expense>.self, from: data) {
                if response.success, let result = response.data {
                    decodedExpense = result
                } else if let error = response.error {
                    throw APIError.serverError(0, error.message)
                }
            } else if let result = try? decoder.decode(Expense.self, from: data) {
                decodedExpense = result
            }
            
            if let expense = decodedExpense {
                self.expense = expense
            } else {
                // If neither decoding strategy worked, throw a generic error
                throw APIError.decodingError("Failed to decode expense after update.")
            }
        } catch {
            errorMessage = error.localizedDescription
            throw error
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
            
            // Flexible decoding
            if let response = try? decoder.decode(MainActorAPIResponse<EmptyResponse>.self, from: data) {
                if !response.success {
                    self.errorMessage = response.error?.message ?? "Failed to delete expense"
                }
            }
            // If it's a 2xx, assume success for delete if no error wrapper found
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
