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
    
    var progressPercentage: Double {
        return Double(progress) / Double(requiredValue) * 100
    }
}

struct AchievementsResponse: Codable {
    let achievements: [Achievement]
    let totalPoints: Int
    let unlockedCount: Int
    let totalCount: Int
}

struct GamificationProfile: Codable {
    let totalPoints: Int
    let currentRank: Int
    let achievementsCount: Int
    let currentStreak: Int
    let longestStreak: Int
    let challengesCompleted: Int
    
    var achievementsUnlocked: Int { achievementsCount }
}
