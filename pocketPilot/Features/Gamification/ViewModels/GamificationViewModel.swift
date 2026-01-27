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
            
            // Log raw data for debugging if needed
            if let jsonString = String(data: data, encoding: .utf8) {
                print("DEBUG: [Gamification] Achievements response: \(jsonString)")
            }
            
            do {
                // Try decoding wrapped in MainActorAPIResponse
                if let response = try? decoder.decode(MainActorAPIResponse<AchievementsResponse>.self, from: data) {
                    if response.success, let result = response.data {
                        self.achievements = result.achievements
                        return
                    }
                }
                
                // Try decoding direct AchievementsResponse (flat)
                if let result = try? decoder.decode(AchievementsResponse.self, from: data) {
                    self.achievements = result.achievements
                    return
                }
                
                // Try decoding direct [Achievement] array (based on user logs)
                if let result = try? decoder.decode([Achievement].self, from: data) {
                    self.achievements = result
                    return
                }
                
                // If we reach here, all decodings failed
                print("DEBUG: [Gamification] Failed to decode achievements response")
                errorMessage = "Failed to parse achievements data"
            }
        } catch {
            print("DEBUG: [Gamification] Load achievements error: \(error)")
            errorMessage = "Failed to load achievements: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @MainActor
    func loadProfile() async {
        do {
            let data = try await apiClient.requestData(.gamificationProfile)
            let decoder = JSONDecoder.api
            
            // Log raw data for debugging if needed
            if let jsonString = String(data: data, encoding: .utf8) {
                print("DEBUG: [Gamification] Profile response: \(jsonString)")
            }
            
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
