//
//  Constants.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation

struct Constants {
    struct API {
        // Update this with your actual backend URL
        static let baseURL = "http://10.12.74.53:8080/api/v1"
        static let timeout: TimeInterval = 30.0
        static let webSocketURL = "ws://10.12.74.53:8080/ws"
    }
    
    struct App {
        static let appName = "PocketPilot"
        static let version = "1.0.0"
    }
    
    struct Keys {
        static let hasOnboarded = "has_onboarded"
        static let selectedCurrency = "selected_currency"
        static let defaultCurrency = "USD"
    }
}
