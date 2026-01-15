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
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search and Filter Header
                    VStack(spacing: 16) {
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            TextField("Search expenses...", text: $viewModel.searchText)
                                .textFieldStyle(.plain)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black.opacity(0.05), lineWidth: 1)
                        )
                        .onChange(of: viewModel.searchText) { _, _ in
                            viewModel.applyFilters()
                        }
                        
                        // Date Range Chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(ExpenseListViewModel.DateRange.allCases, id: \.self) { range in
                                    Button(action: {
                                        withAnimation(.spring()) {
                                            viewModel.selectedDateRange = range
                                            viewModel.applyFilters()
                                        }
                                    }) {
                                        Text(range.rawValue)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(
                                                ZStack {
                                                    if viewModel.selectedDateRange == range {
                                                        Capsule()
                                                            .fill(LinearGradient(colors: [.blue, .blue.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                                                    } else {
                                                        Capsule()
                                                            .fill(Color(.secondarySystemBackground))
                                                    }
                                                }
                                            )
                                            .foregroundColor(viewModel.selectedDateRange == range ? .white : .secondary)
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
                    
                    // Expense Content
                    if viewModel.isLoading {
                        VStack {
                            Spacer()
                            LoadingView(message: "Fetching expenses...")
                            Spacer()
                        }
                    } else if let error = viewModel.errorMessage {
                        VStack {
                            Spacer()
                            ErrorView(message: error) {
                                Task { await viewModel.loadExpenses() }
                            }
                            Spacer()
                        }
                    } else if viewModel.filteredExpenses.isEmpty {
                        emptyState
                    } else {
                        List {
                            Section {
                                ForEach(viewModel.filteredExpenses) { expense in
                                    ExpenseCard(expense: expense)
                                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
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
                        }
                        .listStyle(.plain)
                        .refreshable {
                            await viewModel.loadExpenses()
                        }
                    }
                }
            }
            .navigationTitle("Expenses")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddExpense = true }) {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.blue)
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
    
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "tray.and.arrow.down.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 8) {
                Text("No Expenses Found")
                    .font(.title3)
                    .fontWeight(.bold)
                Text("Start tracking your spending by adding your first expense.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: { showAddExpense = true }) {
                Text("Add First Expense")
                    .fontWeight(.bold)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
            
            Spacer()
        }
    }
}

#Preview {
    ExpenseListView()
}
