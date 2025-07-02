import Foundation
import VinUtility



/// Provides session credentials on runtime.
final actor FPSessionIdentityService: FPSessionIdentityServicing {
    
    
    /// Short-lived token that authenticate you from another 'user' using the service.
    var accessToken: String? {
        didSet {
            VULogger.log("Did set accessToken to: \(accessToken?.prefix(12))")
        }
    }
    var accessTokenExpirationDate: Date?
    
    
    /// Long-lived token that enables ``accessToken`` renewal.
    var refreshToken: String {
        didSet {
            VULogger.log("Did set refreshToken to: \(refreshToken.prefix(12))")
        }
    }
    var refreshTokenExpirationDate: Date
    
    
    /// Authorization level of the token.
    var role: FPTokenRole
    var capabilities: [FPCapability]
    var specialties: [FPIssueType]
    
    
    /// Initializes an instance of ``FPSessionIdentityService``.
    private init(
        accessToken: String? = nil, 
        accessTokenExpirationDate: Date? = nil, 
        refreshToken: String, 
        refreshTokenExpirationDate: Date, 
        role: FPTokenRole,
        capabilities: [FPCapability],
        specialties: [FPIssueType]
    ) {
        self.accessToken = accessToken
        self.accessTokenExpirationDate = accessTokenExpirationDate
        self.refreshToken = refreshToken
        self.refreshTokenExpirationDate = refreshTokenExpirationDate
        self.role = role
        self.capabilities = capabilities
        self.specialties = specialties
    }
    
    
    /// Instantiates a ``FPSessionIdentityService`` following a successful exchange of `Authentication Code` that grants both `Access` and `Refresh` tokens.
    /// 
    /// - Parameter authenticationCode: The code gotten after a successful form submission with `FPNetworkingClient/submitEntryForm(_:)`.
    /// - Parameter networkingClient: The client that will perform exchange operations.
    /// 
    /// > Note: The passed in `networkingClient` will be attached to self's ``networkingClient``.
    /// 
    /// - Returns: An initialized instance of ``FPSessionIdentityService`` via the ``FPSessionIdentityServicing`` interface.
    static func exhangeForTokens(authenticationCode: String, networkingClient: FPNetworkingClient) async -> Result<any FPSessionIdentityServicing, FPError> {
        do {
            switch try await networkingClient.gateway.oauthToken(.init(
                headers: .init(
                    accept: [.init(contentType: .json)]
                ),
                body: .json(.init(data: .init(
                    authentication_code: authenticationCode
                )))
            )) {
                case .ok(let output): switch output.body { case .json(let jsonBody):
                    guard
                        let accessToken = jsonBody.data?.access_token,
                        let accessTokenExpirationDateString = jsonBody.data?.access_expiry_interval,
                        let refreshToken = jsonBody.data?.refresh_token,
                        let refreshTokenExpirationDateString = jsonBody.data?.refresh_expiry_interval,
                        let role = FPTokenRole(rawValue: "\(jsonBody.data?.role_scope?.value ?? "")"),
                        let encodedCapabilities = jsonBody.data?.capabilities,
                        let encodedSpecialties = jsonBody.data?.specialties
                    else {
                        throw FPError.DECODE_FAILURE
                    }
                    
                    let capabilities = encodedCapabilities.compactMap {
                        FPCapability(rawValue: "\($0.value ?? "")")
                    }
                    let specialties: [FPIssueType] = encodedSpecialties.compactMap {
                        guard let id = $0.id, let name = $0.name, let slaDuration = $0.service_level_agreement_duration_hour else { return nil }
                        return FPIssueType(id: id, name: name, serviceLevelAgreementDurationHour: slaDuration)
                    }
                        
                    let selfInstance = FPSessionIdentityService(accessToken: accessToken, 
                                                                accessTokenExpirationDate: .now.addingTimeInterval(Double(accessTokenExpirationDateString)),
                                                                refreshToken: refreshToken, 
                                                                refreshTokenExpirationDate: .now.addingTimeInterval(Double(refreshTokenExpirationDateString)), 
                                                                role: role, 
                                                                capabilities: capabilities, 
                                                                specialties: specialties)
                    return .success(selfInstance)
                }
                    
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



extension FPSessionIdentityService: VUMementoSnapshotable, VUMementoSnapshotBootable {
    
    
    /// Constructs a ``FPSessionIdentityServiceSnapshot``, capturing the current state of the object.
    /// 
    /// - Returns: The snapshot of the object.
    func captureSnapshot() async -> Result<FPSessionIdentityServiceSnapshot, VUError> {
        guard
            let accessToken,
            let accessTokenExpirationDate
        else {
            return .failure(.UNLOADED_ENTRY)
        }
        
        return .success(FPSessionIdentityServiceSnapshot(
            accessToken: accessToken, 
            accessTokenExpirationDate: accessTokenExpirationDate, 
            refreshToken: refreshToken, 
            refreshTokenExpirationDate: refreshTokenExpirationDate, 
            role: role,
            capabilities: capabilities,
            specialties: specialties
        ))
    }
    
    
    /// Restores the state according to the given snapshot.
    ///
    /// - Parameter snapshot: The snapshot to restore from.
    func restore(toSnapshot snapshot: FPSessionIdentityServiceSnapshot) async -> Result<Void, Never> {
        set(accessToken: snapshot.accessToken)
        set(accessTokenExpirationDate: snapshot.accessTokenExpirationDate)
        set(refreshToken: snapshot.refreshToken)
        set(refreshTokenExpirationDate: snapshot.refreshTokenExpirationDate)
        set(role: snapshot.role)
        
        return .success(())
    }
    
    
    
    /// Initializes an object based on the given snapshot.
    ///
    /// - Parameter snapshot: The snapshot to boot from.
    static func boot(fromSnapshot snapshot: FPSessionIdentityServiceSnapshot) -> Result<FPSessionIdentityService, Never> {
        .success(FPSessionIdentityService(
            accessToken: snapshot.accessToken, 
            accessTokenExpirationDate: snapshot.accessTokenExpirationDate,
            refreshToken: snapshot.refreshToken, 
            refreshTokenExpirationDate: snapshot.refreshTokenExpirationDate, 
            role: snapshot.role,
            capabilities: snapshot.capabilities,
            specialties: snapshot.specialties
        ))
    }
    
}
