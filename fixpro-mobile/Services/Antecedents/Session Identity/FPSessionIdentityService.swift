import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import VinUtility



enum TokenRole: String {
    case Member
    case Crew
    case Management
}



/// Provides and manages session credentials on runtime.
class FPSessionIdentityService: FPSessionIdentityServicing {
    
    
    /// Short-lived token that authenticate you from another 'user' using the service.
    var accessToken: String?
    var accessTokenExpirationDate: Date?
    
    
    /// Long-lived token that enables ``accessToken`` renewal.
    var refreshToken: String
    var refreshTokenExpirationDate: Date?
    
    /// Authorization for the set ``accessToken``.
    var role: TokenRole?
    
    
    /// Allows for performing network calls.
    var networkingClient: FPNetworkingClient
    
    
    /// Initializes an instance of ``FPSessionIdentityService``.
    init(refreshToken: String, networkingClient: FPNetworkingClient) {
        self.refreshToken = refreshToken
        self.networkingClient = networkingClient
    }
    
    
    /// Instantiates a ``FPSessionIdentityService`` following a successful exchange of `Authentication Code`, to gain both `Access` and `Refresh` tokens.
    /// 
    /// - Parameter authenticationCode: The code gotten after a successful form submission with `FPNetworkingClient/submitEntryForm(_:)`.
    /// - Parameter endpoint: The url that points to the API of FixPro Backend's of the Area.
    /// - Returns: An initialized instance of ``FPSessionIdentityService`` via the ``FPSessionIdentityServicing`` interface.
    /// 
    /// - Throws:
    ///   - `DECODE_FAILURE` when the backend gives no value for required keys
    ///   - `BAD_REQUEST` when request was missing a valid AuthenticationCode (either empty or an invalid value)
    ///   - `CODE_ALREADY_EXCHANGED` when AuthenticationCode has already been redeemed
    ///   - `UNEXPECTED_RESPONSE` for each unagreed-upon response
    ///   - `UNREACHABLE` on failure to connect with area
    static func exhangeForTokens(authenticationCode: String, endpoint: URL) async -> Result<any FPSessionIdentityServicing, FPError> {
        do {
            VULogger.log(tag: .network, "Exchanging for tokens...")
            let localNetworkingClient = FPNetworkingClient(endpoint: endpoint)
            
            switch try await localNetworkingClient.gateway.exchangeAuthenticationCodeForAccessAndRefreshTokens(.init(
                headers: .init(accept: [.init(
                    contentType: .json
                )]),
                body: .json(.init(
                    authentication_code: authenticationCode,
                    grant_type: "authenticaton_code"
                ))
            )) {
                case .ok(let output): switch output.body { case .json(let jsonBody):
                    guard
                        let accessToken = jsonBody.data?.access_token,
                        let accessTokenExpirationDate = jsonBody.data?.access_expiry_interval,
                        let refreshToken = jsonBody.data?.refresh_token,
                        let refreshTokenExpirationDate = jsonBody.data?.refresh_expiry_interval,
                        let role = jsonBody.data?.role_scope?.rawValue
                    else {
                        throw FPError.DECODE_FAILURE
                    }
                    
                    let selfInstance = FPSessionIdentityService(refreshToken: refreshToken, networkingClient: localNetworkingClient)
                    
                    selfInstance.accessToken = accessToken
                    selfInstance.accessTokenExpirationDate = .now.addingTimeInterval(Double(accessTokenExpirationDate))
                    
                    selfInstance.refreshToken = refreshToken
                    selfInstance.refreshTokenExpirationDate = .now.addingTimeInterval(Double(refreshTokenExpirationDate))
                        
                    selfInstance.role = .init(rawValue: role)
                    
                    VULogger.log(tag: .network, "Successful exchange.")
                    return .success(selfInstance)
                }
                    
                case .noContent:
                    VULogger.log(tag: .network, "AuthenticationCode can only be redeemed once.")
                    return .failure(.CODE_ALREADY_EXCHANGED)
                
                case .badRequest:
                    VULogger.log(tag: .network, "Request was missing a valid AuthenticationCode (either empty or an invalid value)")
                    return .failure(.BAD_REQUEST)
                    
                case .undocumented(statusCode: let code, let payload):
                    VULogger.log(tag: .network, "Area responded with an unexpected response. \(code) • \(payload)")
                    return .failure(.UNEXPECTED_RESPONSE)
            }
            
        } catch {
            VULogger.log(tag: .network, "Unable to contact area. \(error)")
            return .failure(.UNREACHABLE)            
            
        }
    }
    
    
    /// Makes a request for the issuance of a new ``accessToken``, by sending the ``refreshToken`` over.
    /// Upon successful execution, there is a chance that a new ``refreshToken`` is issued.
    /// Whether or not a new ``refreshToken`` is issued, old values of ``accessToken`` and ``refreshToken`` are overwritten.
    /// 
    /// - Returns
    ///   - (PRESENT, NIL) when AccessToken is the only thing getting refreshed.
    ///   - (PRESENT, PRESENT) when both AccessToken and RefreshToken are getting refreshed.
    /// 
    /// - Throws:
    ///   - `DECODE_FAILURE` when the backend gives no value for required keys
    ///   - `INCOMPLETE_ARGUMENT` when RefreshToken wasn't provided
    ///   - `INVALID_TOKEN` when RefreshToken has gone expired or is invalid
    ///   - `FORBIDDEN` when RefreshToken soon becomes invalid
    ///   - `UNEXPECTED_RESPONSE` for each unagreed-upon response
    ///   - `UNREACHABLE` on failure to connect with area
    @discardableResult func refreshAccessToken() async -> Result<(accessToken: String, refreshToken: String?), FPError> {
        do {
            VULogger.log(tag: .network, "Refreshing access token...")
            
            switch try await networkingClient.gateway.refreshAccessTokenWithRefreshToken(.init(
                headers: .init(accept: [.init(contentType: .json)]),
                body: .json(.init(refresh_token: refreshToken))
            )) {
                case .ok(let output): switch output.body { case .json(let jsonBody):
                    guard 
                        let accessToken = jsonBody.data?.access_token,
                        let accessTokenExpirationDate = jsonBody.data?.access_expiry_interval,
                        let role = jsonBody.data?.role_scope?.rawValue
                    else {
                        throw FPError.DECODE_FAILURE
                    }
                    
                    self.accessToken = accessToken
                    self.accessTokenExpirationDate = .now.addingTimeInterval(Double(accessTokenExpirationDate))
                    self.role = .init(rawValue: role)
                    
                    guard
                        let refreshToken = jsonBody.data?.refresh_token,
                        let refreshTokenExpirationDate = jsonBody.data?.refresh_expiry_interval
                    else {
                        VULogger.log(tag: .network, "Successful refresh. No refresh token issued.")
                        return .success((accessToken, nil))
                    }
                    
                    self.refreshToken = refreshToken
                    self.refreshTokenExpirationDate = .now.addingTimeInterval(Double(refreshTokenExpirationDate))
                    
                    VULogger.log(tag: .network, "Successful refresh. New refresh token issued.")
                    return .success((accessToken, refreshToken))
                }
                    
                case .badRequest:
                    VULogger.log(tag: .network, "RefreshToken was not provided in the request.")
                    return .failure(.INCOMPLETE_ARGUMENT)
                    
                case .unauthorized:
                    VULogger.log(tag: .network, "RefreshToken was invalid or has gone expired.")
                    return .failure(.INVALID_TOKEN)
                
                case .forbidden:
                    VULogger.log(tag: .network, "No more refreshes allowed.")
                    return .failure(.FORBIDDEN)
                    
                case .undocumented(statusCode: let code, let payload):
                    VULogger.log(tag: .network, "Area responded with an unexpected response. \(code) • \(payload)")
                    return .failure(.UNEXPECTED_RESPONSE)
            }
            
        } catch {
            VULogger.log(tag: .network, "Unable to contact area. \(error)")
            return .failure(.UNREACHABLE)
            
        }
    }
    
}



extension FPSessionIdentityService: VUMementoSnapshotable {
    
    
    /// Constructs a ``VUMementoSnapshot`` object, capturing the current state of the object.
    /// 
    /// - Returns: The snapshot of the object.
    /// - Throws: 
    ///   - `FPError.UNLOADED_ENTRY` when some of the attributes-to-be-snapped are not present.
    func captureSnapshot() -> Result<any VUMementoSnapshot, VUError> {
        guard
            let accessToken,
            let accessTokenExpirationDate,
            let refreshTokenExpirationDate,
            let role
        else {
            return .failure(.UNLOADED_ENTRY)
        }
        
        let selfSnapshot = FPSessionIdentityServiceSnapshot(accessToken: accessToken, 
                                                            accessTokenExpirationDate: accessTokenExpirationDate, 
                                                            refreshToken: refreshToken, 
                                                            refreshTokenExpirationDate: refreshTokenExpirationDate,
                                                            endpoint: networkingClient.endpoint, 
                                                            role: role.rawValue)
        return .success(selfSnapshot)
    }
    
    
    /// Restores the state according to the given snapshot.
    ///
    /// - Parameter snapshot: The snapshot to restore from.
    /// - Throws:
    ///   - `FPError.TYPE_MISMATCH` when the given ``VUMementoSnapshot`` object cannot be casted into ``FPSessionIdentityServiceSnapshot``.
    func restore(from snapshot: any VUMementoSnapshot) -> Result<Void, VUError> {
        guard let snp = snapshot as? FPSessionIdentityServiceSnapshot else { 
            return .failure(.TYPE_MISMATCH) 
        }
        
        self.accessToken = snp.accessToken
        self.accessTokenExpirationDate = snp.accessTokenExpirationDate
        
        self.refreshToken = snp.refreshToken
        self.refreshTokenExpirationDate = snp.refreshTokenExpirationDate
        
        self.role = .init(rawValue: snp.role)
        
        return .success(())
    }
    
    
    static func restore(from snapshot: FPSessionIdentityServiceSnapshot) -> FPSessionIdentityService {
        let newSelf = FPSessionIdentityService(refreshToken: snapshot.refreshToken, networkingClient: FPNetworkingClient(endpoint: snapshot.endpoint))
        
        newSelf.accessToken = snapshot.accessToken
        newSelf.accessTokenExpirationDate = snapshot.accessTokenExpirationDate
        newSelf.refreshTokenExpirationDate = snapshot.refreshTokenExpirationDate
        newSelf.role = .init(rawValue: snapshot.role)
        
        return newSelf
    }
    
}
