import Foundation
import VinUtility



/// Set of requirements for a service that holds and provides identity used by network requests.
protocol FPSessionIdentityServicing: VUStatefulServicing, Actor {
    
    
    /// Short-lived token that authenticate you from another 'user' using the service.
    var accessToken: String? { get set }
    var accessTokenExpirationDate: Date? { get set }
    
    
    /// Long-lived token that enables ``accessToken`` renewal.
    var refreshToken: String { get set }
    var refreshTokenExpirationDate: Date { get set }
    
    
    /// Authorization level of the token.
    var role: FPTokenRole { get set }
    var capabilities: [FPCapability] { get set }
    var specialties: [FPIssueType] { get set }
    
    
    /// Instantiates a ``FPSessionIdentityService`` following a successful exchange of `Authentication Code` that grants both `Access` and `Refresh` tokens.
    /// 
    /// - Parameter authenticationCode: The code gotten after a successful form submission with `FPNetworkingClient/submitEntryForm(_:)`.
    /// - Parameter networkingClient: The client that will perform exchange operations.
    /// 
    /// > Note: The passed in `networkingClient` will be attached to self's ``networkingClient``.
    /// 
    /// - Returns: An initialized instance of ``FPSessionIdentityService`` via the ``FPSessionIdentityServicing`` interface.
    static func exhangeForTokens(authenticationCode: String, networkingClient: FPNetworkingClient) async -> Result<FPSessionIdentityServicing, FPError>
    
}



/// Setter extensions.
extension FPSessionIdentityServicing {
    
    
    func set(accessToken: String) {
        self.accessToken = accessToken
    }
    
    
    func set(accessTokenExpirationDate: Date?) {
        self.accessTokenExpirationDate = accessTokenExpirationDate
    }
    
    
    func set(refreshToken: String) {
        self.refreshToken = refreshToken
    }
    
    
    func set(refreshTokenExpirationDate: Date) {
        self.refreshTokenExpirationDate = refreshTokenExpirationDate
    }
    
    
    func set(role: FPTokenRole) {
        self.role = role
    }
    
    
    func set(capabilities: [FPCapability]) {
        self.capabilities = capabilities
    }
    
    
    func set(specialties: [FPIssueType]) {
        self.specialties = specialties
    }
    
}
