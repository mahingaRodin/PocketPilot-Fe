//
//  FilterView.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import SwiftUI

struct FilterView: View {
    @Binding var selectedCategory: Category?
    @Binding var selectedDateRange: ExpenseListViewModel.DateRange
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        Text("All Categories").tag(nil as Category?)
                        ForEach(Category.defaultCategories) { category in
                            HStack {
                                if let icon = category.icon {
                                    Image(systemName: icon)
                                }
                                Text(category.name)
                            }
                            .tag(category as Category?)
                        }
                    }
                }
                
                Section("Date Range") {
                    Picker("Date Range", selection: $selectedDateRange) {
                        ForEach(ExpenseListViewModel.DateRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    FilterView(
        selectedCategory: .constant(nil),
        selectedDateRange: .constant(.all)
    )
}
