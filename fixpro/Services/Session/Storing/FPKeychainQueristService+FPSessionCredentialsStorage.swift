extension FPKeychainQueristService: FPSessionCredentialsStorage {
    
    func save(_ token: String, forKey key: String) throws {
        if let tokenData = token.data(using: .utf8) {
            self.place(for: key, data: tokenData)
        }
    }
    
    func retrieve(forKey key: String) throws -> String? {
        switch self.retrieve(for: key) {
            case .success(let token):
                return token
            case .failure(let error):
                throw error
        }
    }
    
    func remove(forKey key: String) throws {
        switch self.remove(for: key) {
            case .success:
                break
            case .failure(let error):
                throw error
        }
    }
    
}
