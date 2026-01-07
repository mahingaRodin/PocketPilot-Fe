//
//  DashboardView.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import SwiftUI

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoading {
                        LoadingView(message: "Loading dashboard...")
                            .frame(height: 400)
                    } else if let error = viewModel.errorMessage {
                        ErrorView(message: error) {
                            Task {
                                await viewModel.loadDashboard()
                            }
                        }
                        .frame(height: 400)
                    } else if let data = viewModel.dashboardData {
                        // Stats Cards
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            StatCard(
                                title: "Total Expenses",
                                value: viewModel.formatCurrency(data.totalExpenses),
                                icon: "dollarsign.circle.fill",
                                color: .red
                            )
                            
                            StatCard(
                                title: "This Month",
                                value: viewModel.formatCurrency(data.monthlyExpenses),
                                icon: "calendar",
                                color: .blue
                            )
                        }
                        .padding(.horizontal)
                        
                        // Monthly Comparison
                        if data.monthlyComparison.changePercentage != 0 {
                            HStack {
                                Image(systemName: data.monthlyComparison.changePercentage > 0 ? "arrow.up.right" : "arrow.down.right")
                                    .foregroundColor(data.monthlyComparison.changePercentage > 0 ? .red : .green)
                                Text("\(abs(data.monthlyComparison.changePercentage), specifier: "%.1f")% from last month")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        // Category Breakdown
                        if !data.categoryBreakdown.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Category Breakdown")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(data.categoryBreakdown.prefix(5)) { breakdown in
                                    CategoryBreakdownRow(breakdown: breakdown)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
                        
                        // Recent Expenses
                        RecentExpensesList(expenses: data.recentExpenses)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            .refreshable {
                await viewModel.loadDashboard()
            }
            .task {
                await viewModel.loadDashboard()
            }
        }
    }
}

struct CategoryBreakdownRow: View {
    let breakdown: CategoryBreakdown
    
    var body: some View {
        HStack {
            if let icon = breakdown.category.icon {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: breakdown.category.color ?? "#95A5A6") ?? .gray)
                    .frame(width: 30)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(breakdown.category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(breakdown.count) expenses")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatCurrency(breakdown.amount))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("\(breakdown.percentage, specifier: "%.1f")%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
}

#Preview {
    DashboardView()
}