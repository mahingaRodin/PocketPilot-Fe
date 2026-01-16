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
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    
    init(expenseId: String) {
        self.expenseId = expenseId
        self._viewModel = State(initialValue: ExpenseDetailViewModel(expenseId: expenseId))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
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
                            // Highlights Card
                            VStack(spacing: 16) {
                                // Category Icon
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: expense.category.color ?? "#3B82F6")?.opacity(0.15) ?? .blue.opacity(0.1))
                                        .frame(width: 80, height: 80)
                                    
                                    if let icon = expense.category.icon {
                                        if expense.category.isEmoji {
                                            Text(icon)
                                                .font(.system(size: 40))
                                        } else {
                                            Image(systemName: icon)
                                                .font(.system(size: 32, weight: .bold))
                                                .foregroundColor(Color(hex: expense.category.color ?? "#3B82F6") ?? .blue)
                                        }
                                    }
                                }
                                
                                VStack(spacing: 4) {
                                    Text(formatCurrency(expense.amount, currency: expense.currency ?? "USD"))
                                        .font(.system(size: 44, weight: .bold, design: .rounded))
                                    
                                    Text(expense.description)
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 32)
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                            .padding(.horizontal)
                            
                            // Receipt Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Receipt")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                if let receiptURL = expense.receiptURL, let url = URL(string: receiptURL) {
                                    NavigationLink(destination: ReceiptPreviewView(url: url)) {
                                        HStack {
                                            Image(systemName: "doc.text.fill")
                                                .foregroundColor(.blue)
                                            Text("View Receipt")
                                                .fontWeight(.medium)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.secondary)
                                        }
                                        .padding()
                                        .background(Color(.systemBackground))
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    }
                                    .padding(.horizontal)
                                } else {
                                    Button(action: {
                                        Task { await viewModel.generateReceipt() }
                                    }) {
                                        HStack {
                                            Image(systemName: "wand.and.stars")
                                            Text("Generate AI Receipt")
                                        }
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.purple.opacity(0.1))
                                        .foregroundColor(.purple)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Details Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Details")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 1) {
                                    infoRow(icon: "tag.fill", label: "Category", value: expense.category.name)
                                    infoRow(icon: "calendar", label: "Date", value: expense.date.formatted(date: .long, time: .omitted))
                                    if let notes = expense.notes, !notes.isEmpty {
                                        infoRow(icon: "note.text", label: "Notes", value: notes)
                                    }
                                }
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .padding(.horizontal)
                            }
                            
                            // Actions
                            VStack(spacing: 12) {
                                Button(action: { showEditSheet = true }) {
                                    Label("Edit Expense", systemImage: "pencil")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                                
                                Button(action: { showDeleteAlert = true }) {
                                    Label("Delete Expense", systemImage: "trash")
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red.opacity(0.1))
                                        .foregroundColor(.red)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showEditSheet) {
                if let expense = viewModel.expense {
                    EditExpenseView(expense: expense, viewModel: viewModel) {
                        NotificationCenter.default.post(name: NSNotification.Name("ExpenseUpdated"), object: nil)
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
                Text("Are you sure you want to delete this expense? This action cannot be undone.")
            }
            .task {
                await viewModel.loadExpense()
            }
        }
    }
    
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding()
        .background(Color(.systemBackground))
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
