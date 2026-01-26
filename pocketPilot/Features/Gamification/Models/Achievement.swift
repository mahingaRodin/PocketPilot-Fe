import Foundation

struct Achievement: Codable, Identifiable {
    let id: UUID
    let code: String
    let name: String
    let description: String
    let category: String
    let icon: String
    let requiredValue: Int
    let points: Int
    let tier: String
    let progress: Int
    let isUnlocked: Bool
    let unlockedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, code, name, description, category, icon, points, tier, progress
        case requiredValue = "required_value"
        case isUnlocked = "is_unlocked"
        case unlockedAt = "unlocked_at"
    }
    
    var progressPercentage: Double {
        return Double(progress) / Double(requiredValue) * 100
    }
}

struct AchievementsResponse: Codable {
    let achievements: [Achievement]
    let totalPoints: Int
    let unlockedCount: Int
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case achievements
        case totalPoints = "total_points"
        case unlockedCount = "unlocked_count"
        case totalCount = "total_count"
    }
}

struct GamificationProfile: Codable {
    let totalPoints: Int
    let currentRank: Int
    let achievementsUnlocked: Int
    let currentStreak: Int
    let longestStreak: Int
    
    enum CodingKeys: String, CodingKey {
        case totalPoints = "total_points"
        case currentRank = "current_rank"
        case achievementsUnlocked = "achievements_unlocked"
        case currentStreak = "current_streak"
        case longestStreak = "longest_streak"
    }
}
