//
//  String+Extensions.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation

extension String {
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isEmptyOrWhitespace: Bool {
        trimmed.isEmpty
    }
    
    func localized() -> String {
        NSLocalizedString(self, comment: "")
    }
}
