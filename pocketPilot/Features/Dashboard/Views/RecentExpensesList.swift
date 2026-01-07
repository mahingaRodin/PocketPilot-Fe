//
//  RecentExpensesList.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import SwiftUI

struct RecentExpensesList: View {
    let expenses: [Expense]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Expenses")
                .font(.headline)
                .padding(.horizontal)
            
            if expenses.isEmpty {
                Text("No recent expenses")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(expenses.prefix(5)) { expense in
                    ExpenseCard(expense: expense)
                        .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
    }
}

#Preview {
    RecentExpensesList(expenses: [])
}