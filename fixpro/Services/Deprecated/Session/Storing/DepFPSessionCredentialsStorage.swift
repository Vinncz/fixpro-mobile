protocol DepFPSessionCredentialsStorage {
    
    func save(sessionCredential information: String, forKey key: String) throws
    func retrieve(sessionCredentialForKey key: String) throws -> String?
    func remove(sessionCredentialForKey key: String) throws
    
}
