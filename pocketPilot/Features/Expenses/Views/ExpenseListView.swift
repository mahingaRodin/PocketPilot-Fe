//
//  ExpenseListView.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import SwiftUI

struct ExpenseListView: View {
    @State private var viewModel = ExpenseListViewModel()
    @State private var showAddExpense = false
    @State private var selectedExpense: Expense?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search and Filter
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search expenses...", text: $viewModel.searchText)
                            .onChange(of: viewModel.searchText) { _, _ in
                                viewModel.applyFilters()
                            }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(ExpenseListViewModel.DateRange.allCases, id: \.self) { range in
                                Button(action: {
                                    viewModel.selectedDateRange = range
                                    viewModel.applyFilters()
                                }) {
                                    Text(range.rawValue)
                                        .font(.subheadline)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(viewModel.selectedDateRange == range ? Color.blue : Color(.systemGray6))
                                        .foregroundColor(viewModel.selectedDateRange == range ? .white : .primary)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                // Expense List
                if viewModel.isLoading {
                    LoadingView(message: "Loading expenses...")
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) {
                        Task {
                            await viewModel.loadExpenses()
                        }
                    }
                } else if viewModel.filteredExpenses.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("No expenses found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.filteredExpenses) { expense in
                            ExpenseCard(expense: expense)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .onTapGesture {
                                    selectedExpense = expense
                                }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let expense = viewModel.filteredExpenses[index]
                                Task {
                                    await viewModel.deleteExpense(expense)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Expenses")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddExpense = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAddExpense) {
                AddExpenseView()
            }
            .sheet(item: $selectedExpense) { expense in
                ExpenseDetailView(expenseId: expense.id)
            }
            .refreshable {
                await viewModel.loadExpenses()
            }
            .task {
                await viewModel.loadExpenses()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ExpenseUpdated"))) { _ in
                Task {
                    await viewModel.loadExpenses()
                }
            }
        }
    }
}

#Preview {
    ExpenseListView()
}
