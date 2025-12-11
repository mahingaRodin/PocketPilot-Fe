
//
//  LoginRequest.swift
//  pocketPilot
//
//  Created by headie-one on 12/11/25.
//

struct LoginRequest: Encodable {
    let email: String
    let password: String
    
    var dictionary: [String: Any] {
        return [
            "email": email,
            "password": password
        ]
    }
}
