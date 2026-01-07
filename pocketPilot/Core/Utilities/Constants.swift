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
        static let baseURL = "https://api.pocketpilot.com"
        static let timeout: TimeInterval = 30.0
        static let webSocketURL = "wss://api.pocketpilot.com/ws"
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