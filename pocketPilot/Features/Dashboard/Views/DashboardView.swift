//
//  DashboardView.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import SwiftUI

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    @State private var appearOpacity = 0.0
    @State private var appearOffset: CGFloat = 20
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        if viewModel.isLoading {
                            LoadingView(message: "Loading dashboard...")
                                .frame(height: 400)
                                .transition(.opacity)
                        } else if let error = viewModel.errorMessage {
                            ErrorView(message: error) {
                                Task { await viewModel.loadDashboard() }
                            }
                            .frame(height: 400)
                            .transition(.opacity)
                        } else if let data = viewModel.dashboardData {
                            // Stats Cards (Staggered)
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                StatCard(
                                    title: "Total Expenses",
                                    value: viewModel.formatCurrency(data.totalExpenses ?? 0),
                                    icon: "dollarsign.circle.fill",
                                    color: .red
                                )
                                .offset(y: appearOffset)
                                .opacity(appearOpacity)
                                .animation(.staggered(index: 0), value: appearOpacity)
                                
                                StatCard(
                                    title: "This Month",
                                    value: viewModel.formatCurrency(data.monthlyExpenses ?? 0),
                                    icon: "calendar",
                                    color: .blue
                                )
                                .offset(y: appearOffset)
                                .opacity(appearOpacity)
                                .animation(.staggered(index: 1), value: appearOpacity)
                            }
                            .padding(.horizontal)
                            
                            // Monthly Comparison
                            if let comparison = data.monthlyComparison, comparison.changePercentage != 0 {
                                HStack {
                                    Image(systemName: comparison.changePercentage > 0 ? "arrow.up.right" : "arrow.down.right")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(comparison.changePercentage > 0 ? .red : .green)
                                    
                                    Text("\(abs(comparison.changePercentage), specifier: "%.1f")% from last month")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(Capsule())
                                .offset(y: appearOffset)
                                .opacity(appearOpacity)
                                .animation(.staggered(index: 2), value: appearOpacity)
                            }
                            
                            // Category Breakdown
                            if let categories = data.categoryBreakdown, !categories.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Category Breakdown")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 16) {
                                            ForEach(Array(categories.prefix(5).enumerated()), id: \.offset) { index, breakdown in
                                                CategoryBreakdownCard(breakdown: breakdown)
                                                    .offset(y: appearOffset)
                                                    .opacity(appearOpacity)
                                                    .animation(.staggered(index: index + 3), value: appearOpacity)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            
                            // Recent Expenses
                            RecentExpensesList(expenses: data.recentExpenses ?? [])
                                .offset(y: appearOffset)
                                .opacity(appearOpacity)
                                .animation(.staggered(index: 8), value: appearOpacity)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Dashboard")
            .refreshable {
                await viewModel.loadDashboard()
            }
            .task {
                await viewModel.loadDashboard()
                withAnimation(.gentle) {
                    appearOpacity = 1.0
                    appearOffset = 0
                }
            }
        }
    }
}

struct CategoryBreakdownCard: View {
    let breakdown: CategoryBreakdown
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: breakdown.category.color ?? "#95A5A6")?.opacity(0.15) ?? .gray.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                if let icon = breakdown.category.icon {
                    if breakdown.category.isEmoji {
                        Text(icon).font(.system(size: 22))
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: breakdown.category.color ?? "#95A5A6") ?? .gray)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(breakdown.category.name)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                Text(formatCurrency(breakdown.amount))
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            Text("\(breakdown.percentage ?? 0.0, specifier: "%.0f")%")
                .font(.caption2)
                .fontWeight(.bold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.1))
                .foregroundColor(.green)
                .clipShape(Capsule())
        }
        .padding()
        .frame(width: 140)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
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
