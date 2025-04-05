extension FPKeychainQueristService: DepFPPairingServiceStorage {
    
    func save(pairingServiceInformation information: String, forKey key: String) throws {
        if let informationData = information.data(using: .utf8) {
            self.place(for: key, data: informationData)
        }
    }
    
    func retrieve(pairingServiceInformationForKey key: String) throws -> String? {
        switch self.retrieve(for: key) {
            case .success(let pairingServiceInformation):
                return pairingServiceInformation
            case .failure(let error):
                throw error
        }
    }
    
    func remove(pairingServiceInformationForKey key: String) throws {
        switch self.remove(for: key) {
            case .success:
                break
            case .failure(let error):
                throw error
        }
    }
    
}

