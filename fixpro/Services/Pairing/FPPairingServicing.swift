protocol FPPairingServicing {
    var referralTrackingIdentifier: String? { get }
    var nonce: String? { get }
    var application_id: String? { get }
    
    func deloadReferralTrackingIdentifier() throws
    func load(referralTrackingIdentifier identifier: String) throws
    
    func deloadNonce() throws
    func load(nonce: String) throws
    
    func populateApplicationId() throws
    func removeApplicationId() throws
    func save(applicationId: String) throws
}
