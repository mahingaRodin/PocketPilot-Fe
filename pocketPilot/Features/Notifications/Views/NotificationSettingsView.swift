//
//  NotificationSettingsView.swift
//  pocketPilot
//
//  Created by headie-one on 01/21/26.
//

import SwiftUI

struct NotificationSettingsView: View {
    @State private var viewModel = NotificationViewModel()
    @State private var budgetAlertsEnabled = true
    @State private var pushEnabled = true
    @State private var quietHoursStart = 22
    @State private var quietHoursEnd = 8
    
    var body: some View {
        Form {
            Section("General") {
                Toggle("Push Notifications", isOn: $pushEnabled)
                Toggle("Budget Alerts", isOn: $budgetAlertsEnabled)
            }
            
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quiet Hours")
                        .font(.headline)
                    Text("Avoid being disturbed during these times. Urgent alerts will still come through.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Start")
                                .font(.caption2)
                                .fontWeight(.bold)
                            Picker("Start", selection: $quietHoursStart) {
                                ForEach(0...23, id: \.self) { hour in
                                    Text("\(hour):00").tag(hour)
                                }
                            }
                            .labelsHidden()
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("End")
                                .font(.caption2)
                                .fontWeight(.bold)
                            Picker("End", selection: $quietHoursEnd) {
                                ForEach(0...23, id: \.self) { hour in
                                    Text("\(hour):00").tag(hour)
                                }
                            }
                            .labelsHidden()
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.vertical, 4)
            } footer: {
                Text("Notifications arriving during quiet hours will be scheduled for when they end.")
            }
            
            Section {
                Button("Save Changes") {
                    let prefs = NotificationPreferences(
                        budgetAlertsEnabled: budgetAlertsEnabled,
                        quietHoursStart: quietHoursStart,
                        quietHoursEnd: quietHoursEnd,
                        pushEnabled: pushEnabled
                    )
                    Task { await viewModel.updatePreferences(prefs) }
                }
                .frame(maxWidth: .infinity)
                .fontWeight(.bold)
                .foregroundStyle(.blue)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Success", isPresented: $viewModel.showSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.successMessage ?? "Changes saved successfully")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
    }
}
