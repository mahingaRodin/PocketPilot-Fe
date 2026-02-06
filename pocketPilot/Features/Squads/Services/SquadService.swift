import Foundation
import Observation
import Alamofire

@MainActor
@Observable
class SquadService {
    static let shared = SquadService()
    
    var squads: [Squad] = []
    var isLoading: Bool = false
    var errorMessage: String?
    
    private let apiClient = APIClient.shared
    
    private init() {}
    
    func fetchSquads() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let data = try await apiClient.requestData(.getSquads)
            
            // Debug: Print raw data
            if let jsonString = String(data: data, encoding: .utf8) {
                print("DEBUG: [SquadService] Raw Fetch Response: \(jsonString)")
            }
            
            let decoder = JSONDecoder.api
            var decodedSquads: [Squad]?
            
            // Try 1: Wrapped in MainActorAPIResponse
            do {
                let response = try decoder.decode(MainActorAPIResponse<[Squad]>.self, from: data)
                decodedSquads = response.data
                print("DEBUG: [SquadService] Successfully decoded using MainActorAPIResponse strategy")
            } catch {
                print("DEBUG: [SquadService] MainActorAPIResponse strategy mismatch: \(error). Trying direct array...")
                
                // Try 2: Direct array
                do {
                    decodedSquads = try decoder.decode([Squad].self, from: data)
                    print("DEBUG: [SquadService] Successfully decoded using direct array strategy")
                } catch {
                    print("DEBUG: [SquadService] Direct array strategy mismatch: \(error). Trying wrapper...")
                    
                    // Try 3: Wrapped in a "squads" key
                    do {
                        let squadWrapper = try decoder.decode(SquadWrapper.self, from: data)
                        decodedSquads = squadWrapper.squads
                        print("DEBUG: [SquadService] Successfully decoded using SquadWrapper strategy")
                    } catch {
                        print("DEBUG: [SquadService] SquadWrapper strategy mismatch: \(error). Trying paginated...")
                        
                        // Try 4: Paginated response
                        do {
                            let paginatedResponse = try decoder.decode(PaginatedAPIResponse<Squad>.self, from: data)
                            decodedSquads = paginatedResponse.data
                            print("DEBUG: [SquadService] Successfully decoded using PaginatedAPIResponse strategy")
                        } catch {
                            print("DEBUG: [SquadService] PaginatedAPIResponse strategy mismatch: \(error)")
                            
                            // Try 5: If it's a dictionary but doesn't match above, print keys
                            if let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                                print("DEBUG: [SquadService] Decoding failed. JSON keys present: \(dict.keys.joined(separator: ", "))")
                            }
                        }
                    }
                }
            }
            
            if let squads = decodedSquads {
                self.squads = squads
            } else {
                errorMessage = "Failed to decode squads data. Check console for details."
            }
        } catch {
            print("DEBUG: [SquadService] Request failed: \(error)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }

    private struct SquadWrapper: Decodable {
        let squads: [Squad]
    }
    
    func createSquad(name: String, description: String?) async throws -> Squad? {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let request = CreateSquadRequest(name: name, description: description)
        let data = try await apiClient.requestData(
            .createSquad,
            method: .post,
            parameters: request.dictionary
        )
        
        // Try decoding as Squad directly first (since backend might return SquadResponse)
        if let newSquad = try? JSONDecoder.api.decode(Squad.self, from: data) {
            squads.append(newSquad)
            return newSquad
        }
        
        // Then try wrapped response
        let response = try JSONDecoder.api.decode(MainActorAPIResponse<Squad>.self, from: data)
        if response.success {
            if let newSquad = response.data {
                squads.append(newSquad)
                return newSquad
            }
        } else {
            errorMessage = response.error?.message
            throw APIError.serverError(0, errorMessage ?? "Failed to create squad")
        }
        return nil
    }
    
    func joinSquad(inviteCode: String) async throws -> Squad? {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let request = JoinSquadRequest(inviteCode: inviteCode)
        let data = try await apiClient.requestData(
            .joinSquad,
            method: .post,
            parameters: request.dictionary
        )
        
        // Try decoding as Squad directly first
        if let squad = try? JSONDecoder.api.decode(Squad.self, from: data) {
            squads.append(squad)
            return squad
        }
        
        // Then try wrapped
        let response = try JSONDecoder.api.decode(MainActorAPIResponse<Squad>.self, from: data)
        if response.success {
            if let squad = response.data {
                squads.append(squad)
                return squad
            }
        } else {
            errorMessage = response.error?.message
            throw APIError.serverError(0, errorMessage ?? "Failed to join squad")
        }
        return nil
    }
    
    func fetchMembers(squadID: String) async throws -> [SquadMemberResponse] {
        let data = try await apiClient.requestData(.getSquadMembers(squadID))
        let decoder = JSONDecoder.api
        
        // Try 1: Direct array
        if let members = try? decoder.decode([SquadMemberResponse].self, from: data) {
            return members
        }
        
        // Try 2: Wrapped
        let response = try decoder.decode(MainActorAPIResponse<[SquadMemberResponse]>.self, from: data)
        return response.data ?? []
    }
    
    func deleteSquad(id: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        let _ = try await apiClient.requestData(.deleteSquad(id), method: .delete)
        
        // Remove from local list upon success
        squads.removeAll { $0.id == id }
    }
    
    func fetchSettlements(squadID: String) async throws -> [SquadSettlement] {
        let data = try await apiClient.requestData(.getSquadSettlements(squadID))
        
        // Debug: Print raw data
        if let jsonString = String(data: data, encoding: .utf8) {
            print("DEBUG: [SquadService] Raw Settlements Response: \(jsonString)")
        }
        
        let decoder = JSONDecoder.api
        
        // Try 1: Direct array (Most likely from backend)
        if let settlements = try? decoder.decode([SquadSettlement].self, from: data) {
            print("DEBUG: [SquadService] Successfully decoded settlements using direct array strategy")
            return settlements
        }
        
        // Try 2: Wrapped in MainActorAPIResponse
        if let response = try? decoder.decode(MainActorAPIResponse<[SquadSettlement]>.self, from: data),
           response.success {
            print("DEBUG: [SquadService] Successfully decoded settlements using MainActorAPIResponse strategy")
            return response.data ?? []
        }
        
        // Try 3: Paginated
        if let response = try? decoder.decode(PaginatedAPIResponse<SquadSettlement>.self, from: data) {
            print("DEBUG: [SquadService] Successfully decoded settlements using PaginatedAPIResponse strategy")
            return response.data
        }
        
        print("DEBUG: [SquadService] Failed to decode settlements")
        if let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            print("DEBUG: [SquadService] Settlements keys: \(dict.keys.joined(separator: ", "))")
        }
        
        throw APIError.decodingError("Failed to decode settlements data")
    }
}
