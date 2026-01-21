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
        if authManager.isAuthenticated {
            MainTabView()
        } else {
            LoginView()
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
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
    }
}

// MARK: - Previews

#Preview {
    ContentView()
        .environment(AuthManager.shared)  // ← .environment here too
}
