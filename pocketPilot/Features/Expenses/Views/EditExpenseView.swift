//
//  EditExpenseView.swift
//  pocketPilot
//
//  Created by headie-one on 15/01/26.
//

import SwiftUI

struct EditExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var notes: String = ""
    @State private var selectedCategory: Category
    @State private var date: Date = Date()
    @State private var currency: String = "USD"
    @State private var showSuccess: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    let viewModel: ExpenseDetailViewModel
    let onUpdate: () -> Void
    
    init(expense: Expense, viewModel: ExpenseDetailViewModel, onUpdate: @escaping () -> Void) {
        _amount = State(initialValue: String(format: "%.2f", expense.amount))
        _description = State(initialValue: expense.description)
        _notes = State(initialValue: expense.notes ?? "")
        _selectedCategory = State(initialValue: expense.category)
        _date = State(initialValue: expense.date)
        _currency = State(initialValue: expense.currency ?? "USD")
        self.viewModel = viewModel
        self.onUpdate = onUpdate
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Amount Header
                        VStack(spacing: 8) {
                            Text("Amount")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(currency)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                
                                TextField("0.00", text: $amount)
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.center)
                                    .fixedSize()
                            }
                        }
                        .padding(.vertical, 32)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                        
                        // Details Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Expense Details")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 1) {
                                detailRow(icon: "doc.text.fill", title: "Description") {
                                    TextField("What was it for?", text: $description)
                                }
                                
                                detailRow(icon: "tag.fill", title: "Category") {
                                    Picker("", selection: $selectedCategory) {
                                        ForEach(Category.defaultCategories) { category in
                                            HStack {
                                                if let icon = category.icon {
                                                    if category.isEmoji {
                                                        Text(icon)
                                                    } else {
                                                        Image(systemName: icon)
                                                    }
                                                }
                                                Text(category.name)
                                            }
                                            .tag(category)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                                
                                detailRow(icon: "calendar", title: "Date") {
                                    DatePicker("", selection: $date, displayedComponents: .date)
                                        .labelsHidden()
                                }
                                
                                detailRow(icon: "note.text", title: "Notes") {
                                    TextField("Optional notes", text: $notes)
                                }
                            }
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal)
                        }
                        
                        if let error = errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                        
                        // Update Button
                        Button(action: {
                            Task {
                                await saveChanges()
                            }
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView().tint(.white).padding(.trailing, 8)
                                }
                                Text("Update Expense")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(colors: [.blue, .blue.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .disabled(isLoading || amount.isEmpty || description.isEmpty)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 32)
                }
                
                if showSuccess {
                    SuccessOverlayView(message: "Expense Updated!", isPresented: $showSuccess)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .navigationTitle("Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    private func detailRow<Content: View>(icon: String, title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            content()
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private func saveChanges() async {
        guard let amountValue = Double(amount) else {
            errorMessage = "Invalid amount"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await viewModel.updateExpense(
                amount: amountValue,
                description: description,
                category: selectedCategory.name.lowercased(),
                date: date,
                notes: notes.isEmpty ? nil : notes
            )
            // Reload the expense to get the updated receipt URL (backend regenerates on update)
            await viewModel.loadExpense()
            onUpdate()
            
            // Trigger budget threshold check
            Task {
                let budgetVM = BudgetViewModel()
                await budgetVM.checkThresholds()
            }
            
            withAnimation { showSuccess = true }
            try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
