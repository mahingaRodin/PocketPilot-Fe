import Foundation
import Observation
import Alamofire

@Observable
class GamificationViewModel {
    var achievements: [Achievement] = []
    var profile: GamificationProfile?
    var isLoading = false
    var errorMessage: String?
    var showConfetti = false
    
    private let apiClient = APIClient.shared
    
    @MainActor
    func loadAchievements() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let data = try await apiClient.requestData(.achievements)
            let decoder = JSONDecoder.api
            
            if let response = try? decoder.decode(MainActorAPIResponse<AchievementsResponse>.self, from: data) {
                if response.success, let result = response.data {
                    achievements = result.achievements
                }
            } else if let result = try? decoder.decode(AchievementsResponse.self, from: data) {
                achievements = result.achievements
            }
        } catch {
            print("DEBUG: [Gamification] Load achievements error: \(error)")
            errorMessage = "Failed to load achievements"
        }
        
        isLoading = false
    }
    
    @MainActor
    func loadProfile() async {
        do {
            let data = try await apiClient.requestData(.gamificationProfile)
            let decoder = JSONDecoder.api
            
            if let response = try? decoder.decode(MainActorAPIResponse<GamificationProfile>.self, from: data) {
                if response.success, let result = response.data {
                    profile = result
                }
            } else if let result = try? decoder.decode(GamificationProfile.self, from: data) {
                profile = result
            }
        } catch {
            print("DEBUG: [Gamification] Load profile error: \(error)")
        }
    }
    
    @MainActor
    func checkAchievements() async {
        do {
            let _ = try await apiClient.requestData(
                .checkAchievements,
                method: .post
            )
            
            // Reload achievements and profile
            await loadAchievements()
            await loadProfile()
            
            // Show celebration if new achievement (simplified check)
            showConfetti = true
        } catch {
            print("DEBUG: [Gamification] Check achievements error: \(error)")
        }
    }
    
    var unlockedAchievements: [Achievement] {
        achievements.filter { $0.isUnlocked }
    }
    
    var lockedAchievements: [Achievement] {
        achievements.filter { !$0.isUnlocked }
    }
}
