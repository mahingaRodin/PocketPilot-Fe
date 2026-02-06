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
                    .transition(.opacity)
            } else {
                LoginView()
                    .transition(.opacity)
            }
            
            // Full Screen Welcome/Loading View
            if authManager.showWelcomeMessage, let message = authManager.welcomeMessage {
                WelcomeView(message: message)
                    .zIndex(1) // Ensure it stays on top
                    .transition(.opacity)
                    .onAppear {
                        // Dismiss after 3 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            withAnimation(.easeOut(duration: 0.5)) {
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
                    Label("Dash", systemImage: "chart.bar.fill")
                }
                .tag(0)
            
            SquadListView()
                .tabItem {
                    Label("Squads", systemImage: "person.3.fill")
                }
                .tag(1)
            
            ExpenseListView()
                .tabItem {
                    Label("Expenses", systemImage: "list.bullet")
                }
                .tag(2)
            
            BudgetDashboardView()
                .tabItem {
                    Label("Budgets", systemImage: "chart.pie.fill")
                }
                .tag(3)
            
            AchievementsView()
                .tabItem {
                    Label("Gamify", systemImage: "trophy.fill")
                }
                .tag(4)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(5)
        }
    }
}

// MARK: - Previews

#Preview {
    ContentView()
        .environment(AuthManager.shared)  // ← .environment here too
}
