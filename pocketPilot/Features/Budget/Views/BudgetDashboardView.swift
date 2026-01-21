//
//  BudgetDashboardView.swift
//  pocketPilot
//
//  Created by headie-one on 01/21/26.
//

import SwiftUI

struct BudgetDashboardView: View {
    @State private var viewModel = BudgetViewModel()
    @State private var showCreateBudget = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        if let summary = viewModel.summary {
                            // Overall Summary Card
                            OverallSummaryCard(summary: summary)
                            
                            // Alerts Section
                            if !viewModel.alerts.filter({ !$0.isRead }).isEmpty {
                                AlertsSection(
                                    alerts: viewModel.alerts,
                                    onMarkRead: { alertId in
                                        Task {
                                            try? await viewModel.markAlertAsRead(alertId: alertId)
                                        }
                                    }
                                )
                            }
                            
                            // Budget Categories
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Budget Categories")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                    
                                    Button {
                                        showCreateBudget = true
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                            .foregroundStyle(.blue)
                                    }
                                }
                                
                                if summary.budgets.isEmpty {
                                    EmptyBudgetView {
                                        showCreateBudget = true
                                    }
                                } else {
                                    LazyVStack(spacing: 16) {
                                        ForEach(summary.budgets) { budgetStatus in
                                            BudgetCard(budgetStatus: budgetStatus)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        } else if viewModel.isLoading {
                            VStack {
                                Spacer()
                                ProgressView()
                                    .scaleEffect(1.5)
                                Text("Loading budgets...")
                                    .foregroundStyle(.secondary)
                                    .padding()
                                Spacer()
                            }
                            .frame(minHeight: 400)
                        } else {
                            // Initial state or error
                            VStack(spacing: 16) {
                                Image(systemName: "chart.pie.fill")
                                    .font(.system(size: 60))
                                    .foregroundStyle(.blue.opacity(0.3))
                                
                                Text("No budget data available")
                                    .font(.headline)
                                
                                Button {
                                    Task { await viewModel.loadBudgetSummary() }
                                } label: {
                                    Text("Retry")
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 12)
                                        .background(.blue)
                                        .foregroundColor(.white)
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.top, 100)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Budgets")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreateBudget = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateBudget) {
                CreateBudgetView { category, amount, period, threshold in
                    Task {
                        try? await viewModel.createBudget(
                            category: category,
                            amount: amount,
                            period: period,
                            alertThreshold: threshold
                        )
                    }
                }
            }
            .refreshable {
                await viewModel.loadBudgetSummary()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred")
            }
        }
        .task {
            await viewModel.loadBudgetSummary()
        }
    }
}

// MARK: - Overall Summary Card
struct OverallSummaryCard: View {
    let summary: BudgetSummary
    
    var body: some View {
        VStack(spacing: 20) {
            // Total Budget vs Spent
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Monthly Budget")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    Text("$\(summary.totalBudget, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total Spent")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    Text("$\(summary.totalSpent, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(summary.overallPercentage > 100 ? .red : .primary)
                }
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("\(Int(summary.overallPercentage))% Used")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(summary.overallPercentage > 100 ? .red : .secondary)
                    
                    Spacer()
                    
                    Text("$\(summary.totalRemaining, specifier: "%.2f") \(summary.totalRemaining >= 0 ? "Left" : "Over")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(summary.totalRemaining >= 0 ? .green : .red)
                }
                
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 12)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: progressColors(percentage: summary.overallPercentage),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, min(1.0, summary.overallPercentage / 100)) * (UIScreen.main.bounds.width - 64), height: 12)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
    
    private func progressColors(percentage: Double) -> [Color] {
        if percentage < 80 {
            return [.green, .green.opacity(0.7)]
        } else if percentage < 100 {
            return [.orange, .orange.opacity(0.7)]
        } else {
            return [.red, .red.opacity(0.7)]
        }
    }
}

// MARK: - Alerts Section
struct AlertsSection: View {
    let alerts: [BudgetAlert]
    let onMarkRead: (UUID) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Priority Alerts")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(alerts.filter { !$0.isRead }) { alert in
                        AlertCard(alert: alert) {
                            onMarkRead(alert.id)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct AlertCard: View {
    let alert: BudgetAlert
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(alertColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: alertIcon)
                    .foregroundStyle(alertColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(alertTypeText)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(alertColor)
                
                if let message = alert.message {
                    Text(message)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .frame(maxWidth: 180, alignment: .leading)
                }
            }
            
            Button {
                withAnimation { onDismiss() }
            } label: {
                Image(systemName: "xmark")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.gray)
                    .padding(6)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
    
    private var alertIcon: String {
        switch alert.alertType {
        case "approaching": return "exclamationmark.triangle.fill"
        case "warning": return "exclamationmark.triangle.fill"
        case "exceeded": return "xmark.octagon.fill"
        default: return "info.circle.fill"
        }
    }
    
    private var alertColor: Color {
        switch alert.alertType {
        case "approaching": return .orange
        case "warning": return .red
        case "exceeded": return .red
        default: return .blue
        }
    }
    
    private var alertTypeText: String {
        switch alert.alertType {
        case "approaching": return "NEAR LIMIT"
        case "warning": return "WARNING"
        case "exceeded": return "EXCEEDED"
        default: return "INFO"
        }
    }
}

// MARK: - Budget Card
struct BudgetCard: View {
    let budgetStatus: BudgetStatus
    @State private var showDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                // Category Icon
                let matchingCategory = Category.findMatch(for: budgetStatus.budget.category)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    if let icon = budgetStatus.budget.categoryIcon {
                        Text(icon)
                            .font(.title3)
                    } else {
                        Image(systemName: matchingCategory?.icon ?? "cart.fill")
                            .font(.title3)
                            .foregroundStyle(.blue)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(budgetStatus.budget.categoryDisplay ?? budgetStatus.budget.category.capitalized)
                        .font(.headline)
                    
                    HStack(spacing: 4) {
                        Text("$\(budgetStatus.spent, specifier: "%.0f")")
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        Text("of $\(budgetStatus.budget.amount, specifier: "%.0f")")
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: budgetStatus.statusIcon)
                            .font(.caption2)
                        Text(statusText.uppercased())
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(budgetStatus.statusColor).opacity(0.1))
                    .foregroundStyle(Color(budgetStatus.statusColor))
                    .clipShape(Capsule())
                    
                    Text("\(budgetStatus.daysRemaining) days left")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(Color(budgetStatus.statusColor))
                            .frame(width: max(0, min(1.0, budgetStatus.percentage / 100)) * geo.size.width, height: 8)
                    }
                }
                .frame(height: 8)
                
                HStack {
                    if budgetStatus.onTrack {
                        Text("On track for \(budgetStatus.budget.period)")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    } else {
                        Text("Over pace • Projected: $\(budgetStatus.projectedTotal, specifier: "%.0f")")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                    
                    Spacer()
                    
                    Text("$\(budgetStatus.remaining, specifier: "%.0f") remaining")
                        .font(.caption2)
                        .fontWeight(.bold)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onTapGesture {
            showDetails = true
        }
        .sheet(isPresented: $showDetails) {
            // Basic Detail View for now
            BudgetDetailView(budgetStatus: budgetStatus)
        }
    }
    
    private var statusText: String {
        switch budgetStatus.status {
        case "on_track": return "On Track"
        case "approaching": return "Approaching"
        case "warning": return "Warning"
        case "exceeded": return "Exceeded"
        default: return budgetStatus.status
        }
    }
}

// MARK: - Empty Budget View
struct EmptyBudgetView: View {
    let onCreate: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.system(size: 32))
                    .foregroundStyle(.blue)
            }
            
            VStack(spacing: 8) {
                Text("No Budgets Yet")
                    .font(.headline)
                
                Text("Set monthly limits for categories like Food, Travel, or Shopping.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button {
                onCreate()
            } label: {
                Text("Create New Budget")
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 40)
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

// MARK: - Supporting Views (Simplified for integration)

struct BudgetDetailView: View {
    let budgetStatus: BudgetStatus
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = BudgetViewModel()
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Status") {
                    LabeledContent("Category", value: budgetStatus.budget.categoryDisplay ?? budgetStatus.budget.category.capitalized)
                    LabeledContent("Amount", value: String(format: "$%.2f", budgetStatus.budget.amount))
                    LabeledContent("Spent", value: String(format: "$%.2f", budgetStatus.spent))
                    LabeledContent("Remaining", value: String(format: "$%.2f", budgetStatus.remaining))
                    LabeledContent("Percentage", value: "\(Int(budgetStatus.percentage))%")
                }
                
                Section("Analysis") {
                    LabeledContent("Daily Average", value: String(format: "$%.2f", budgetStatus.averageDaily))
                    LabeledContent("Projected Total", value: String(format: "$%.2f", budgetStatus.projectedTotal))
                    LabeledContent("Status", value: budgetStatus.status.replacingOccurrences(of: "_", with: " ").capitalized)
                    LabeledContent("On Track", value: budgetStatus.onTrack ? "Yes" : "No")
                }
                
                Section {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Text("Delete Budget")
                    }
                }
            }
            .navigationTitle("Budget Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Delete Budget", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        try? await viewModel.deleteBudget(budgetId: budgetStatus.budget.id)
                        dismiss()
                    }
                }
            } message: {
                Text("Are you sure you want to delete this budget?")
            }
        }
    }
}

struct CreateBudgetView: View {
    var onCreate: (String, Double, String, Double) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedCategory = "food"
    @State private var amount = ""
    @State private var alertThreshold = 80.0
    
    let categories = ["food", "transportation", "shopping", "utilities", "entertainment", "healthcare", "education", "travel", "other"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category.capitalized).tag(category)
                        }
                    }
                }
                
                Section("Budget Amount") {
                    TextField("Enter amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                Section("Alert Threshold (\(Int(alertThreshold))%)") {
                    Slider(value: $alertThreshold, in: 50...100, step: 5)
                    Text("We'll notify you when you've spent \(Int(alertThreshold))% of your budget.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        if let amountDouble = Double(amount) {
                            onCreate(selectedCategory, amountDouble, "monthly", alertThreshold)
                            dismiss()
                        }
                    }
                    .disabled(amount.isEmpty)
                }
            }
        }
    }
}
