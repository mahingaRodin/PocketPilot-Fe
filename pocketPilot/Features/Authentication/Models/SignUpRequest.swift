struct SignUpRequest: Codable, Sendable {
    let email: String
    let password: String
    let firstName: String
    let lastName: String
    let confirmPassword: String
    
    var dictionary: [String: Any] {
        return [
            "email": email,
            "password": password,
            "firstName": firstName,
            "lastName": lastName,
            "confirmPassword": confirmPassword
        ]
    }
}
