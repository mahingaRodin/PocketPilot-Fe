//
//  Category.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

import Foundation

struct Category: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let icon: String?
    let color: String?
    
    static let defaultCategories: [Category] = [
        Category(id: "1", name: "Food & Dining", icon: "fork.knife", color: "#FF6B6B"),
        Category(id: "2", name: "Transportation", icon: "car.fill", color: "#4ECDC4"),
        Category(id: "3", name: "Shopping", icon: "bag.fill", color: "#45B7D1"),
        Category(id: "4", name: "Bills & Utilities", icon: "bolt.fill", color: "#FFA07A"),
        Category(id: "5", name: "Entertainment", icon: "tv.fill", color: "#98D8C8"),
        Category(id: "6", name: "Healthcare", icon: "cross.case.fill", color: "#F7DC6F"),
        Category(id: "7", name: "Education", icon: "book.fill", color: "#BB8FCE"),
        Category(id: "8", name: "Travel", icon: "airplane", color: "#85C1E2"),
        Category(id: "9", name: "Other", icon: "ellipsis.circle.fill", color: "#95A5A6")
    ]
    
    var isEmoji: Bool {
        guard let icon = icon else { return false }
        for scalar in icon.unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
                 0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                 0x1F680...0x1F6FF, // Transport and Map
                 0x1F1E6...0x1F1FF, // Flags
                 0x2600...0x26FF,   // Misc Symbols
                 0x2700...0x27BF,   // Dingbats
                 0xFE00...0xFE0F,   // Variation Selectors
                 0x1F900...0x1F9FF: // Supplemental Symbols and Pictographs
                return true
            default:
                continue
            }
        }
        return false
    }
    
    static func findMatch(for name: String) -> Category? {
        let normalizedName = name.lowercased()
        return defaultCategories.first { defaultCat in
            let defName = defaultCat.name.lowercased()
            let defId = defaultCat.id.lowercased()
            return defName == normalizedName || 
                   defId == normalizedName ||
                   defName.contains(normalizedName) ||
                   normalizedName.contains(defName)
        }
    }
}