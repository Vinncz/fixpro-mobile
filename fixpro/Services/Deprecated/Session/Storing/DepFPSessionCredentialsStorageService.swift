class DepFPSessionCredentialsStorageService: DepFPSessionCredentialsStoring {
    
    private(set) var accessToken: String?
    private(set) var refreshToken: String?
    private(set) var authorizationCode: String?
    
    private let storage: DepFPSessionCredentialsStorage
    init(storage: DepFPSessionCredentialsStorage) {
        self.storage = storage
    }
    
    enum Subject: String, CaseIterable {
        case accessToken
        case authorizationCode
        case refreshToken
    }
    
}    


extension DepFPSessionCredentialsStorageService {
    
    func populateRefreshToken() throws {
        refreshToken = try storage.retrieve(sessionCredentialForKey: Subject.refreshToken.rawValue)
    }
    
    func removeRefreshToken() throws {
        try storage.remove(sessionCredentialForKey: Subject.refreshToken.rawValue)
        refreshToken = nil
    }
    
    func save(refreshToken token: String) throws {
        try storage.save(sessionCredential: token, forKey: Subject.refreshToken.rawValue)
    }

}


extension DepFPSessionCredentialsStorageService {
    
    func populateAccessToken() throws {
        accessToken = try storage.retrieve(sessionCredentialForKey: Subject.accessToken.rawValue)
    }
    
    func removeAccessToken() throws {
        try storage.remove(sessionCredentialForKey: Subject.accessToken.rawValue)
        accessToken = nil
    }
    
    func save(accessToken token: String) throws {
        try storage.save(sessionCredential: token, forKey: Subject.accessToken.rawValue)
    }
    
}


extension DepFPSessionCredentialsStorageService {
    
    func populateAuthorizationCode() throws {
        authorizationCode = try storage.retrieve(sessionCredentialForKey: Subject.authorizationCode.rawValue)
    }
    
    func removeAuthorizationCode() throws {
        try storage.remove(sessionCredentialForKey: Subject.authorizationCode.rawValue)
        authorizationCode = nil
    }
    
    func save(authorizationCode code: String) throws {
        try storage.save(sessionCredential: code, forKey: Subject.authorizationCode.rawValue)
    }
    
}
