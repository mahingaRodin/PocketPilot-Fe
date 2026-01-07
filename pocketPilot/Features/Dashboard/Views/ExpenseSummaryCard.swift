//
//  ExpenseSummaryCard.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import SwiftUI

struct ExpenseSummaryCard: View {
    let title: String
    let amount: Double
    let currency: String
    let icon: String
    let color: Color
    
    var body: some View {
        StatCard(
            title: title,
            value: formatCurrency(amount, currency: currency),
            icon: icon,
            color: color
        )
    }
    
    private func formatCurrency(_ amount: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: amount)) ?? "\(currency) \(amount)"
    }
}

#Preview {
    ExpenseSummaryCard(
        title: "Total Expenses",
        amount: 1234.56,
        currency: "USD",
        icon: "dollarsign.circle.fill",
        color: .blue
    )
}