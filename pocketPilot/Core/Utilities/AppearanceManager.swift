import SwiftUI
import Observation

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { self.rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

@Observable
class AppearanceManager {
    static let shared = AppearanceManager()
    
    var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "app_theme")
        }
    }
    
    private init() {
        let savedTheme = UserDefaults.standard.string(forKey: "app_theme") ?? "System"
        self.currentTheme = AppTheme(rawValue: savedTheme) ?? .system
    }
}
