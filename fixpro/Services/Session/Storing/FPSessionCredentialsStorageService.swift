class FPSessionCredentialsStorageService: FPSessionCredentialsStoring {
    
    enum Subject: String, CaseIterable {
        case accessToken
        case authorizationCode
        case refreshToken
    }
    
    var accessToken: String?
    var refreshToken: String?
    var authorizationCode: String?
    
    private let storage: FPSessionCredentialsStorage
    init(storage: FPSessionCredentialsStorage) {
        self.storage = storage
    }
    
}    


extension FPSessionCredentialsStorageService {
    
    func populateRefreshToken() throws {
        refreshToken = try storage.retrieve(forKey: Subject.refreshToken.rawValue)
    }
    
    func removeRefreshToken() throws {
        try storage.remove(forKey: Subject.refreshToken.rawValue)
        refreshToken = nil
    }
    
    func save(refreshToken token: String) throws {
        try storage.save(token, forKey: Subject.refreshToken.rawValue)
    }

}


extension FPSessionCredentialsStorageService {
    
    func populateAccessToken() throws {
        accessToken = try storage.retrieve(forKey: Subject.accessToken.rawValue)
    }
    
    func removeAccessToken() throws {
        try storage.remove(forKey: Subject.accessToken.rawValue)
        accessToken = nil
    }
    
    func save(accessToken token: String) throws {
        try storage.save(token, forKey: Subject.accessToken.rawValue)
    }
    
}


extension FPSessionCredentialsStorageService {
    
    func populateAuthorizationCode() throws {
        authorizationCode = try storage.retrieve(forKey: Subject.authorizationCode.rawValue)
    }
    
    func removeAuthorizationCode() throws {
        try storage.remove(forKey: Subject.authorizationCode.rawValue)
        authorizationCode = nil
    }
    
    func save(authorizationCode code: String) throws {
        try storage.save(code, forKey: Subject.authorizationCode.rawValue)
    }
    
}
