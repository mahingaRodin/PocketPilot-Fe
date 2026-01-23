//
//  ReportHistoryView.swift
//  pocketPilot
//
//  Created by headie-one on 01/21/26.
//

import SwiftUI

struct ReportHistoryView: View {
    @State private var viewModel = ReportViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var downloadingReportID: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.reports.isEmpty {
                    ProgressView()
                } else if viewModel.reports.isEmpty {
                    ContentUnavailableView(
                        "No Reports",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text("Generate your first expense report from the export screen.")
                    )
                } else {
                    List {
                        ForEach(viewModel.reports) { report in
                            ReportRow(report: report, isDownloading: downloadingReportID == report.filename) {
                                Task {
                                    downloadingReportID = report.filename
                                    await FileSharer.shared.downloadAndShare(
                                        filename: report.filename,
                                        endpoint: .downloadReport(report.filename)
                                    )
                                    downloadingReportID = nil
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .refreshable {
                        await viewModel.fetchReports()
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                await viewModel.fetchReports()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred")
            }
        }
    }
}

struct ReportRow: View {
    let report: ReportItem
    let isDownloading: Bool
    let onShare: () -> Void
    
    var body: some View {
        Button {
            onShare()
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isCSV ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: isCSV ? "tablecells" : "doc.richtext")
                        .foregroundStyle(isCSV ? .green : .red)
                        .font(.title3)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(report.filename)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                    
                    if let date = report.createdAt {
                        Text(date, style: .date)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                if isDownloading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(.blue)
                }
            }
            .padding(.vertical, 4)
        }
        .disabled(isDownloading)
    }
    
    private var isCSV: Bool {
        report.filename.lowercased().hasSuffix(".csv")
    }
}

#Preview {
    ReportHistoryView()
}
