protocol DepFPPairingServiceStorage {
    
    func save(pairingServiceInformation information: String, forKey key: String) throws
    func retrieve(pairingServiceInformationForKey key: String) throws -> String?
    func remove(pairingServiceInformationForKey key: String) throws
    
}
