protocol DepFPPairingServicing {
    
    var endpoint: String? { get }
    var referralTrackingIdentifier: String? { get }
    var nonce: String? { get }
    var applicationId: String? { get }
    
    func deloadEndpoint()
    func load(endpoint: String)
    
    func deloadReferralTrackingIdentifier()
    func load(referralTrackingIdentifier identifier: String)
    
    func deloadNonce()
    func load(nonce: String)
    
    func populateApplicationId() throws
    func removeApplicationId() throws
    func save(applicationId: String) throws
    
    func fetchFormFields() async throws -> [String]
    func submitForm(withAnswersOf answers: [String: String]) async throws -> String
    
}
