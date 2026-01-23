//
//  ReportViewModel.swift
//  pocketPilot
//
//  Created by headie-one on 01/21/26.
//

import Foundation
import Observation
import Alamofire

@MainActor
@Observable
class ReportViewModel {
    var reports: [ReportItem] = []
    var isLoading = false
    var isExporting = false
    var errorMessage: String?
    var showError = false
    var lastExportedFilename: String?
    var lastDownloadUrl: String?
    
    private let apiClient = APIClient.shared
    
    func fetchReports() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let data = try await apiClient.requestData(.listReports)
            let decoder = JSONDecoder.api
            
            // Debug logging
            if let raw = String(data: data, encoding: .utf8) {
                print("DEBUG: [Reports] Raw list response: \(raw)")
            }
            
            if let response = try? decoder.decode([ReportItem].self, from: data) {
                reports = response
            } else if let response = try? decoder.decode(MainActorAPIResponse<[ReportItem]>.self, from: data), let dataObj = response.data {
                reports = dataObj
            } else if let response = try? decoder.decode(ReportListResponse.self, from: data) {
                reports = response.reports
            } else if let response = try? decoder.decode(MainActorAPIResponse<ReportListResponse>.self, from: data), let dataObj = response.data {
                reports = dataObj.reports
            } else {
                print("DEBUG: [Reports] Failed to decode reports list")
            }
        } catch {
            print("DEBUG: [Reports] Failed to fetch reporting history: \(error)")
            errorMessage = "Failed to load report history"
            showError = true
        }
        
        isLoading = false
    }
    
    func export(format: String, startDate: Date?, endDate: Date?, category: String?) async -> Bool {
        isExporting = true
        errorMessage = nil
        
        let formatter = ISO8601DateFormatter()
        let startStr = startDate.map { formatter.string(from: $0) }
        let endStr = endDate.map { formatter.string(from: $0) }
        
        // Normalize category to lowercase if search matching backend expectation
        // But backend guide uses "Food & Dining" (Upper), so let's stick to display name or whatever user selected.
        let params: [String: Any?] = [
            "format": format,
            "start_date": startStr,
            "end_date": endStr,
            "category": category == "All" ? nil : category
        ]
        
        // Remove nil values
        let filteredParams = params.compactMapValues { $0 }
        
        do {
            let data = try await apiClient.requestData(
                .exportExpenses,
                method: .post,
                parameters: filteredParams as [String : Any]
            )
            
            let decoder = JSONDecoder.api
            var response: ExportResponse?
            
            if let flat = try? decoder.decode(ExportResponse.self, from: data) {
                response = flat
            } else if let wrapped = try? decoder.decode(MainActorAPIResponse<ExportResponse>.self, from: data), let dataObj = wrapped.data {
                response = dataObj
            }
            
            if let result = response, result.success {
                lastExportedFilename = result.filename
                lastDownloadUrl = result.downloadUrl
                await fetchReports()
                isExporting = false
                return true
            } else {
                errorMessage = response?.message ?? "Export failed"
                showError = true
            }
        } catch {
            print("DEBUG: [Reports] Export error: \(error)")
            errorMessage = "Failed to generate report"
            showError = true
        }
        
        isExporting = false
        return false
    }
    
    func getDownloadURL(for filename: String) -> URL? {
        // Construct full URL with token if needed, or use the relative path provided by backend
        // APIClient.shared.apiBaseURL + "/api/v1/reports/download/" + filename
        // But the download endpoint usually requires the same Auth header.
        // We might need a helper to download the file data first then share it.
        return nil 
    }
}
