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
    var downloadedFileURL: URL?
    var showDownloadSuccess: Bool = false
    
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
    
    func generateReceipt() async {
        guard let expense = expense else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let data = try await apiClient.requestData(
                .generateReceipt(expense.id),
                method: .post
            )
            
            if let json = String(data: data, encoding: .utf8) {
                 print("DEBUG: [Receipt] Generate response: \(json)")
            }
            
            let decoder = JSONDecoder.api
            var decodedExpense: Expense?
            
            if let response = try? decoder.decode(MainActorAPIResponse<Expense>.self, from: data) {
                if response.success, let result = response.data {
                    decodedExpense = result
                } else if let error = response.error {
                    self.errorMessage = error.message
                }
            } else if let result = try? decoder.decode(Expense.self, from: data) {
                decodedExpense = result
            } else if let path = String(data: data, encoding: .utf8), path.contains("/") {
                // Fallback: If backend returns raw string path (e.g. "/receipts/file.pdf")
                // We manually update the local expense with this path
                print("DEBUG: [Receipt] Received path string, updating local expense.")
                var updated = expense
                // Remove quotes if present
                let cleanPath = path.replacingOccurrences(of: "\"", with: "")
                updated.receiptURL = cleanPath
                decodedExpense = updated
            }
            
            if let newExpense = decodedExpense {
                self.expense = newExpense
                // Notify list to update
                 NotificationCenter.default.post(name: NSNotification.Name("ExpenseUpdated"), object: nil)
            } else {
                 print("DEBUG: [Receipt] Failed to decode as Expense or path")
                 throw APIError.decodingError("Could not decode receipt response")
            }
        } catch {
            print("DEBUG: [Receipt] Error: \(error)")
            errorMessage = "Failed to generate receipt: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func downloadReceipt() async {
        guard let expense = expense else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let data = try await apiClient.requestData(.downloadReceipt(expense.id))
            
            // Create a temporary file to save the receipt
            let fileName = "receipt-\(expense.description.replacingOccurrences(of: " ", with: "-"))-\(expense.id.prefix(6)).html"
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            try data.write(to: tempURL)
            
            self.downloadedFileURL = tempURL
            self.showDownloadSuccess = true
            
            // Auto hide success message after 3 seconds
            try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
            self.showDownloadSuccess = false
            
        } catch {
            print("DEBUG: [Receipt] Download error: \(error)")
            errorMessage = "Failed to download receipt: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
