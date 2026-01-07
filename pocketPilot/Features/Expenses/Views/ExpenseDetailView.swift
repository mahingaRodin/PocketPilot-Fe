//
//  ExpenseDetailView.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import SwiftUI

struct ExpenseDetailView: View {
    let expenseId: String
    @State private var viewModel: ExpenseDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false
    
    init(expenseId: String) {
        self.expenseId = expenseId
        self._viewModel = State(initialValue: ExpenseDetailViewModel(expenseId: expenseId))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isLoading {
                    LoadingView(message: "Loading expense...")
                        .frame(height: 400)
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) {
                        Task {
                            await viewModel.loadExpense()
                        }
                    }
                    .frame(height: 400)
                } else if let expense = viewModel.expense {
                    VStack(spacing: 24) {
                        // Amount
                        VStack(spacing: 8) {
                            Text(formatCurrency(expense.amount, currency: expense.currency))
                                .font(.system(size: 48, weight: .bold))
                            Text(expense.description)
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        
                        // Details
                        VStack(alignment: .leading, spacing: 16) {
                            DetailRow(title: "Category", value: expense.category.name)
                            DetailRow(title: "Date", value: expense.date.formatted(style: .medium))
                            if let location = expense.location {
                                DetailRow(title: "Location", value: location.address ?? "Unknown")
                            }
                            if !expense.tags.isEmpty {
                                DetailRow(title: "Tags", value: expense.tags.joined(separator: ", "))
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Delete Button
                        Button(action: { showDeleteAlert = true }) {
                            Text("Delete Expense")
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Expense Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Delete Expense", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        await viewModel.deleteExpense()
                        NotificationCenter.default.post(name: NSNotification.Name("ExpenseUpdated"), object: nil)
                        dismiss()
                    }
                }
            } message: {
                Text("Are you sure you want to delete this expense?")
            }
            .task {
                await viewModel.loadExpense()
            }
        }
    }
    
    private func formatCurrency(_ amount: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: amount)) ?? "\(currency) \(amount)"
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    ExpenseDetailView(expenseId: "1")
}
