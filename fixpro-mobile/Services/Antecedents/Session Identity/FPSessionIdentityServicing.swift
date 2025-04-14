import Foundation
import VinUtility



/// Set of requirements for a service that manages identity between sessions.
protocol FPSessionIdentityServicing: VUStatefulServicing {
    
    
    /// Short-lived token that authenticate you from another 'user' using the service.
    var accessToken: String? { get }
    
    
    /// Long-lived token that enables ``accessToken`` renewal.
    var refreshToken: String { get }
    
    
    /// Instantiates a ``FPSessionIdentityService`` following a successful exchange of `Authentication Code`, to gain both `Access` and `Refresh` tokens.
    /// 
    /// - Parameter authenticationCode: The code gotten after a successful form submission with `FPNetworkingClient/submitEntryForm(_:)`.
    /// - Parameter endpoint: The url that points to the API of FixPro Backend's of the Area.
    /// 
    /// - Returns: An initialized instance of ``FPSessionIdentityService`` via the ``FPSessionIdentityServicing`` interface.
    static func exhangeForTokens(authenticationCode: String, endpoint: URL) async -> Result<FPSessionIdentityServicing, FPError>
    
    
    /// Makes a request for the issuance of a new ``accessToken``, by sending the ``refreshToken`` over.
    /// Upon successful execution, there is a chance that a new ``refreshToken`` is issued.
    /// Whether or not a new ``refreshToken`` is issued, old values of ``accessToken`` and ``refreshToken`` are overwritten.
    @discardableResult func refreshAccessToken() async -> Result<(accessToken: String, refreshToken: String?), FPError>
    
}
