//
//  NotificationListView.swift
//  pocketPilot
//
//  Created by headie-one on 01/21/26.
//

import SwiftUI

struct NotificationListView: View {
    @State private var viewModel = NotificationViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.notifications.isEmpty {
                    ProgressView()
                } else if viewModel.notifications.isEmpty {
                    ContentUnavailableView(
                        "No Notifications",
                        systemImage: "bell.slash",
                        description: Text("You're all caught up! New alerts will appear here.")
                    )
                } else {
                    List {
                        ForEach(viewModel.notifications) { notification in
                            NotificationRow(notification: notification) {
                                Task { 
                                    await viewModel.markAsRead(notificationId: notification.id) 
                                    viewModel.navigate(for: notification)
                                    dismiss()
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.fetchNotifications()
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            viewModel.clearAll()
                        } label: {
                            Text("Clear")
                        }
                        
                        Button("Done") { dismiss() }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Menu {
                            Button {
                                Task { await viewModel.triggerTestBudgetAlert() }
                            } label: {
                                Label("Test Budget Alert", systemImage: "chart.pie")
                            }
                            
                            Button {
                                Task { await viewModel.triggerTestDailySummary() }
                            } label: {
                                Label("Test Daily Summary", systemImage: "doc.text")
                            }
                        } label: {
                            Image(systemName: "flask")
                        }
                        
                        Button {
                            Task { await viewModel.markAllAsRead() }
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                        }
                    }
                }
            }
            .task {
                await viewModel.fetchNotifications()
            }
        }
    }
}

struct NotificationRow: View {
    let notification: Notification
    let onRead: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon based on type/category
            ZStack {
                Circle()
                    .fill(colorForType.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: iconForType)
                    .font(.title3)
                    .foregroundStyle(colorForType)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text(notification.createdAt, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            if !notification.isRead {
                Circle()
                    .fill(.blue)
                    .frame(width: 8, height: 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onTapGesture {
            if !notification.isRead {
                onRead()
            }
        }
    }
    
    private var iconForType: String {
        switch notification.type {
        case "budget_alert": return "exclamationmark.triangle.fill"
        case "daily_summary": return "list.bullet.clipboard.fill"
        case "unusual_spending": return "bolt.shield.fill"
        default: return "bell.fill"
        }
    }
    
    private var colorForType: Color {
        switch notification.type {
        case "budget_alert": return .orange
        case "unusual_spending": return .red
        case "daily_summary": return .blue
        default: return .blue
        }
    }
}
