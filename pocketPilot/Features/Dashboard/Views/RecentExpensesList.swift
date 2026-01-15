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
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Expenses")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Spacer()
                
                if !expenses.isEmpty {
                    NavigationLink {
                        ExpenseListView()
                    } label: {
                        Text("See All")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .padding(.horizontal)
            
            if expenses.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary.opacity(0.3))
                    Text("No recent expenses")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(expenses.prefix(5)) { expense in
                        ExpenseCard(expense: expense)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    RecentExpensesList(expenses: [])
}