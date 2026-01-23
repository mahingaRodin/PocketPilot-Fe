//
//  ExportView.swift
//  pocketPilot
//
//  Created by headie-one on 01/21/26.
//

import SwiftUI

struct ExportView: View {
    @State private var viewModel = ReportViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedFormat = "csv"
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var selectedCategory = "All"
    @State private var showHistory = false
    @State private var isDownloading = false
    
    let formats = ["csv", "pdf"]
    let categories = ["All"] + Category.defaultCategories.map { $0.name }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Format") {
                    Picker("Export Format", selection: $selectedFormat) {
                        Text("CSV (Excel)").tag("csv")
                        Text("PDF Report").tag("pdf")
                    }
                    .pickerStyle(.segmented)
                    
                    Text(selectedFormat == "pdf" ? "Creates a beautiful, printable HTML report." : "Standard spreadsheet format for data analysis.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Section("Date Range") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
                
                Section("Filter") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                }
                
                Section {
                    Button {
                        Task {
                            let success = await viewModel.export(
                                format: selectedFormat,
                                startDate: startDate,
                                endDate: endDate,
                                category: selectedCategory
                            )
                            
                            if success, let filename = viewModel.lastExportedFilename {
                                isDownloading = true
                                await FileSharer.shared.downloadAndShare(
                                    filename: filename,
                                    endpoint: .downloadReport(filename)
                                )
                                isDownloading = false
                            }
                        }
                    } label: {
                        HStack {
                            if viewModel.isExporting || isDownloading {
                                ProgressView()
                                    .padding(.trailing, 8)
                            }
                            Text(isDownloading ? "Downloading..." : (viewModel.isExporting ? "Generating..." : "Generate & View Report"))
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(viewModel.isExporting || isDownloading)
                } footer: {
                    Text("The report will be generated and opened in the system previewer.")
                }
                
                Section {
                    Button {
                        showHistory = true
                    } label: {
                        Label("View Export History", systemImage: "clock.arrow.circlepath")
                    }
                }
            }
            .navigationTitle("Export Expenses")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showHistory) {
                ReportHistoryView()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred")
            }
        }
    }
}

#Preview {
    ExportView()
}
