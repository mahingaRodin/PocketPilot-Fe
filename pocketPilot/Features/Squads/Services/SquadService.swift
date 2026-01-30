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
            let response = try JSONDecoder.api.decode(MainActorAPIResponse<[Squad]>.self, from: data)
            
            if response.success {
                squads = response.data ?? []
            } else {
                errorMessage = response.error?.message
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
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
    
    func fetchSettlements(squadID: String) async throws -> [SquadSettlement] {
        let data = try await apiClient.requestData(.getSquadSettlements(squadID))
        let response = try JSONDecoder.api.decode(MainActorAPIResponse<[SquadSettlement]>.self, from: data)
        
        if response.success {
            return response.data ?? []
        } else {
            throw APIError.serverError(0, response.error?.message ?? "Failed to fetch settlements")
        }
    }
}
