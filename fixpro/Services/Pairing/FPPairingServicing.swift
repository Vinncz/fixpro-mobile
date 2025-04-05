import Foundation


protocol FPPairingServicing: FPLiminalService, FPStatefulService {
    
    var endpoint: String? { get set }
    var referralTrackingIdentifier: String?  { get set }
    var nonce: String? { get set }
    var applicationId: String? { get set }
    
    
    /// Saves an information so it survives app termination.
    func persists(_ information: String, forKey key: String) -> Result<Void, FPError>
    
    
    /// Fetches the fields necessary to fill out the entry form that is set by an Area.
    func getFormFieldsAndNonce() async -> Result<(fields: [String], nonce: String), FPError>
    
    
    /// Submits the answer of the form to the Area.
    /// @returns The application ID, which acts as a proof that one has requested entry by filling out the form.
    func getApplicationId(bySubmittingTheFormFillout formFillout: [String: String]) async -> Result<String, FPError>
    
    
    /// Performs a lookup with the saved ``applicationId`` whether self has been given access to use FixPro inside an Area.
    /// @returns an OAuth-compliant `authenticationCode`, which has a short lifespan, and need to be as quickly as possible exchanged with tokens.
    func checkForApproval() async -> Result<String, FPError>
    
}
