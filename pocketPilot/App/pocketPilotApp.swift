//
//  pocketPilotApp.swift
//  pocketPilot
//
//  Created by headie-one on 12/10/25.
//

import SwiftUI

@main
struct pocketPilotApp: App {
    
    @State private var authManager = AuthManager.shared 
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
        }
    }
}
