//
//  DashboardView.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import SwiftUI

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    @State private var notificationManager = NotificationManager.shared
    @State private var appearOpacity = 0.0
    @State private var appearOffset: CGFloat = 20
    @State private var gamificationViewModel = GamificationViewModel()
    @State private var showScanner = false
    @State private var showNotifications = false
    
    // Removed duplicate 'currency' state if it existed or ensuring clean state
    // DashboardView doesn't have currency state in previous read, but AddExpenseView did.
    // Focusing on inserting TrendChart.
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
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
                            
                            // Trend Chart
                            TrendChartView(data: viewModel.trendData)
                                .offset(y: appearOffset)
                                .opacity(appearOpacity)
                                .animation(.staggered(index: 2), value: appearOpacity)
                            
                            // Recent Expenses
                            RecentExpensesList(expenses: data.recentExpenses ?? [])
                                .offset(y: appearOffset)
                                .opacity(appearOpacity)
                                .animation(.staggered(index: 3), value: appearOpacity)
                            
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
                                                    .animation(.staggered(index: index + 4), value: appearOpacity)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            
                            // Achievement Widgets
                            VStack(spacing: 20) {
                                if let profile = gamificationViewModel.profile {
                                    StreakWidget(
                                        currentStreak: profile.currentStreak,
                                        longestStreak: profile.longestStreak
                                    )
                                    .padding(.horizontal)
                                    .offset(y: appearOffset)
                                    .opacity(appearOpacity)
                                    .animation(.staggered(index: 5), value: appearOpacity)
                                }
                                
                                RecentAchievementsRow(achievements: gamificationViewModel.unlockedAchievements)
                                    .padding(.horizontal)
                                    .offset(y: appearOffset)
                                    .opacity(appearOpacity)
                                    .animation(.staggered(index: 6), value: appearOpacity)
                            }
                            .padding(.bottom, 24)
                        }
                    }
                    .padding(.vertical)
                }
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
                
                // Floating Action Buttons
                VStack {
                    Spacer()
                    HStack(spacing: 20) {
                        Spacer()
                        
                        FloatingChatButton()
                        
                        Button {
                            showScanner = true
                        } label: {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(
                                    LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .clipShape(Circle())
                                .shadow(color: .blue.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNotifications = true
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "bell.fill")
                                .font(.title3)
                                .foregroundStyle(.primary)
                            
                            if notificationManager.unreadCount > 0 {
                                Text("\(notificationManager.unreadCount)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .padding(4)
                                    .background(.red)
                                    .clipShape(Circle())
                                    .offset(x: 10, y: -10)
                            }
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showScanner) {
                ReceiptScannerView(isPresented: $showScanner)
            }
            .sheet(isPresented: $showNotifications) {
                NotificationListView()
            }
            .refreshable {
                await viewModel.loadDashboard()
                await notificationManager.fetchUnreadCount()
            }
            .task {
                await viewModel.loadDashboard()
                await viewModel.loadTrendData()
                await gamificationViewModel.loadAchievements()
                await gamificationViewModel.loadProfile()
                await notificationManager.fetchUnreadCount()
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

// MARK: - Gamification Widgets
struct StreakWidget: View {
    let currentStreak: Int
    let longestStreak: Int
    
    var body: some View {
        HStack(spacing: 20) {
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.title)
                        .foregroundStyle(.orange)
                    
                    Text("\(currentStreak)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                }
                
                Text("Day Streak")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
                .frame(height: 50)
            
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .font(.title3)
                        .foregroundStyle(.yellow)
                    
                    Text("\(longestStreak)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                }
                
                Text("Best Streak")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 5)
    }
}

struct MiniAchievementBadge: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
            }
            .shadow(color: .orange.opacity(0.3), radius: 5, x: 0, y: 2)
            
            Text(achievement.name)
                .font(.system(size: 10, weight: .bold))
                .lineLimit(1)
                .frame(width: 70)
        }
    }
}

struct RecentAchievementsRow: View {
    let achievements: [Achievement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(.yellow)
                Text("Recent Achievements")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Spacer()
            }
            
            if achievements.isEmpty {
                HStack {
                    Image(systemName: "star.bubble")
                        .font(.title3)
                        .foregroundColor(.blue)
                    Text("No achievements yet. Keep tracking to unlock!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(achievements.prefix(5)) { achievement in
                            MiniAchievementBadge(achievement: achievement)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 5)
    }
}
