//
//  ContentView.swift
//  pocketPilot
//
//  Created by headie-one on 12/10/25.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(AuthManager.self) var authManager  // ← new @Environment syntax for @Observable types
    
    var body: some View {
        ZStack {
            if authManager.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
            
            // Welcome Message Overlay
            if authManager.showWelcomeMessage, let message = authManager.welcomeMessage {
                VStack {
                    HStack(spacing: 12) {
                        Image(systemName: "hand.wave.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .symbolEffect(.bounce, value: authManager.showWelcomeMessage)
                        
                        Text(message)
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(
                        ZStack {
                            Capsule()
                                .fill(LinearGradient(
                                    colors: [Color.blue, Color(red: 0.2, green: 0.3, blue: 0.9)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                            
                            Capsule()
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                        }
                    )
                    .shadow(color: .blue.opacity(0.4), radius: 15, x: 0, y: 8)
                    .padding(.top, 64) 
                    .transition(.move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.9)))
                    
                    Spacer()
                }
                .zIndex(100) // Ensure it's above everything
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            authManager.showWelcomeMessage = false
                        }
                    }
                }
            }
        }
    }
}

struct MainTabView: View {
    @State private var notificationManager = NotificationManager.shared
    
    var body: some View {
        TabView(selection: $notificationManager.selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                .tag(0)
            
            ExpenseListView()
                .tabItem {
                    Label("Expenses", systemImage: "list.bullet")
                }
                .tag(1)
            
            BudgetDashboardView()
                .tabItem {
                    Label("Budgets", systemImage: "chart.pie.fill")
                }
                .tag(2)
            
            AchievementsView()
                .tabItem {
                    Label("Achievements", systemImage: "trophy.fill")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
        }
    }
}

// MARK: - Previews

#Preview {
    ContentView()
        .environment(AuthManager.shared)  // ← .environment here too
}
