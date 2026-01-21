//
//  Report.swift
//  pocketPilot
//
//  Created by headie-one on 01/21/26.
//

import Foundation

struct ReportItem: Codable, Identifiable {
    var id: String { filename }
    let filename: String
    let downloadUrl: String
    let createdAt: Date? // Some endpoints might return this
    
    enum CodingKeys: String, CodingKey {
        case filename
        case downloadUrl = "download_url"
        case createdAt = "created_at"
    }
}

struct ExportRequest: Codable {
    let format: String
    let startDate: String?
    let endDate: String?
    let category: String?
    
    enum CodingKeys: String, CodingKey {
        case format
        case startDate = "start_date"
        case endDate = "end_date"
        case category
    }
}

struct ExportResponse: Codable {
    let success: Bool
    let filename: String?
    let downloadUrl: String?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case success
        case filename
        case downloadUrl = "download_url"
        case message
    }
}

struct ReportListResponse: Codable {
    let reports: [ReportItem]
}
