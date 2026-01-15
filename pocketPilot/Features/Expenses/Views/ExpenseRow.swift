//
//  ExpenseRow.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import SwiftUI

struct ExpenseRow: View {
    let expense: Expense
    let onTap: () -> Void
    
    var body: some View {
        ExpenseCard(expense: expense)
            .onTapGesture {
                onTap()
            }
    }
}

#Preview {
    ExpenseRow(expense: Expense(
        id: "1",
        userID: "user1",
        teamID: nil,
        amount: 50.0,
        currency: "USD",
        category: Category.defaultCategories[0],
        description: "Lunch",
        date: Date(),
        receiptURL: nil,
        notes: nil,
        tags: [],
        createdAt: Date(),
        updatedAt: Date()
    ), onTap: {})
}
