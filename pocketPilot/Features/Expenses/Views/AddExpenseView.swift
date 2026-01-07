//
//  AddExpenseView.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var selectedCategory: Category = Category.defaultCategories[0]
    @State private var date: Date = Date()
    @State private var currency: String = "USD"
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    private let apiClient = APIClient.shared
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    HStack {
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                        Picker("Currency", selection: $currency) {
                            Text("USD").tag("USD")
                            Text("EUR").tag("EUR")
                            Text("GBP").tag("GBP")
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("Details") {
                    TextField("Description", text: $description)
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(Category.defaultCategories) { category in
                            HStack {
                                if let icon = category.icon {
                                    Image(systemName: icon)
                                }
                                Text(category.name)
                            }
                            .tag(category)
                        }
                    }
                    CustomDatePicker(title: "Date", date: $date)
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveExpense()
                        }
                    }
                    .disabled(isLoading || amount.isEmpty || description.isEmpty)
                }
            }
        }
    }
    
    private func saveExpense() async {
        guard let amountValue = Double(amount) else {
            errorMessage = "Invalid amount"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let parameters: [String: Any] = [
            "amount": amountValue,
            "currency": currency,
            "description": description,
            "category_id": selectedCategory.id,
            "date": ISO8601DateFormatter().string(from: date)
        ]
        
        do {
            let _: Expense = try await apiClient.request(
                .createExpense,
                method: .post,
                parameters: parameters
            )
            NotificationCenter.default.post(name: NSNotification.Name("ExpenseUpdated"), object: nil)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    AddExpenseView()
}
