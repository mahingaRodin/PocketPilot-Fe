struct SignUpRequest: Encodable {
    let email: String
    let password: String
    let name: String
    
    var dictionary: [String: Any] {
        return [
            "email": email,
            "password": password,
            "name": name
        ]
    }
}
