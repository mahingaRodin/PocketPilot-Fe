
import SwiftUI

struct ReceiptReviewView: View {
    @State var scanResult: ReceiptScanResult
    @Binding var isPresented: Bool
    
    // We can pass this data to AddExpenseView, or save directly. 
    // For "Unified Form", we might just want to use this view to prep the data 
    // and then push AddExpenseView, or have this View ACT as the form.
    // Given the complexity, let's make this view manage the data and have a "Continue" action.
    
    @State private var merchantName: String = ""
    @State private var amount: Double = 0.0
    @State private var date: Date = Date()
    @State private var selectedCategory: String = "Other"
    @State private var items: [ReceiptItem] = []
    
    // Navigation to actual AddExpenseView
    @State private var navigateToAddExpense = false
    
    var body: some View {
        NavigationStack {
            Form {
                if scanResult.needsReview || scanResult.confidence < 0.8 {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                            Text("Please double-check the details.")
                                .font(.subheadline)
                        }
                    }
                }
                
                Section(header: Text("Receipt Details")) {
                    TextField("Merchant", text: $merchantName)
                    
                    HStack {
                        Text(Locale.current.currencySymbol ?? "$")
                        TextField("Amount", value: $amount, format: .number.precision(.fractionLength(2)))
                            .keyboardType(.decimalPad)
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    // Simple Category Picker - should match app categories
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(["Food", "Shopping", "Transport", "Utilities", "Entertainment", "Healthcare", "Travel", "Other"], id: \.self) {
                            Text($0)
                        }
                    }
                }
                
                if !items.isEmpty {
                    Section(header: Text("Items")) {
                        ForEach(items) { item in
                            HStack {
                                Text("\(item.quantity)x \(item.name)")
                                Spacer()
                                Text(item.price, format: .currency(code: "USD"))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Review Receipt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Next") {
                        navigateToAddExpense = true
                    }
                }
            }
            .onAppear {
                populateFields()
            }
            .navigationDestination(isPresented: $navigateToAddExpense) {
                // Here we would navigate to AddExpenseView pre-filled.
                // Since I can't easily import AddExpenseView due to circular refs or just structure,
                // I'll assume AddExpenseView exists and will be updated to accept these params.
                // For now, I'll place a placeholder.
                Text("Proceed to Add Expense with: \(merchantName), \(amount)")
            }
        }
    }
    
    private func populateFields() {
        merchantName = scanResult.merchantName ?? ""
        amount = scanResult.amount ?? 0.0
        date = scanResult.date ?? Date()
        selectedCategory = scanResult.suggestedCategory ?? "Other"
        items = scanResult.items ?? []
    }
}
