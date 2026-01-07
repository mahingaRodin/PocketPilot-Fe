//
//  UserDefaultsManager.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - Currency
    
    func saveCurrency(_ currency: String) {
        userDefaults.set(currency, forKey: Constants.Keys.selectedCurrency)
    }
    
    func getCurrency() -> String {
        return userDefaults.string(forKey: Constants.Keys.selectedCurrency) ?? Constants.Keys.defaultCurrency
    }
    
    // MARK: - Onboarding
    
    func setHasOnboarded(_ hasOnboarded: Bool) {
        userDefaults.set(hasOnboarded, forKey: Constants.Keys.hasOnboarded)
    }
    
    func hasOnboarded() -> Bool {
        return userDefaults.bool(forKey: Constants.Keys.hasOnboarded)
    }
    
    // MARK: - Clear All
    
    func clearAll() {
        let domain = Bundle.main.bundleIdentifier!
        userDefaults.removePersistentDomain(forName: domain)
        userDefaults.synchronize()
    }
}
