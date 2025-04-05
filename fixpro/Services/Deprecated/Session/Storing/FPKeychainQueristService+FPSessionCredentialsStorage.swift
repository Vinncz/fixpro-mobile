extension FPKeychainQueristService: DepFPSessionCredentialsStorage {
    
    func save(sessionCredential information: String, forKey key: String) throws {
        if let informationData = information.data(using: .utf8) {
            self.place(for: key, data: informationData)
        }
    }
    
    func retrieve(sessionCredentialForKey key: String) throws -> String? {
        switch self.retrieve(for: key) {
            case .success(let sessionCredential):
                return sessionCredential
            case .failure(let error):
                throw error
        }
    }
    
    func remove(sessionCredentialForKey key: String) throws {
        switch self.remove(for: key) {
            case .success:
                break
            case .failure(let error):
                throw error
        }
    }
    
}
