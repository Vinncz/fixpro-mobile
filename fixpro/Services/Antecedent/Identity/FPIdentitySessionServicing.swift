import Foundation


protocol FPIdentitySessionServicing: FPStatefulService, FPAntecedentService, FPTransitionCompatibleService {
    
    var authenticationCode: String? { get }
    var accessToken: String? { get }
    var refreshToken: String? { get }
    
    
    /// Invokes a network call to exchange the authentication code received post-transition
    /// with access and refresh tokens, and saves them.
    func exhangeCodeForTokensAndSaveThem() async -> Result<Void, FPError>
    
    
    /// Invokes a network call that renews ``accessToken`` by passing the ``refreshToken`` over.
    /// The expected response should contain a new access token, that should be saved. 
    /// In case where a new refresh token is issued, the new invalidates the old, and it is saved.
    func refreshAndSaveNewAccessToken() async -> Result<Void, FPError>
    
}
