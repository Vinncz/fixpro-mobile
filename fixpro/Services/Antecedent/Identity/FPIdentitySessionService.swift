import Foundation


class FPIdentitySessionService: FPIdentitySessionServicing {
    
    var authenticationCode: String?
    var accessToken: String?
    var refreshToken: String?
    
    var networkingClient: FPNetworkingClient
    var storage: any FPTextStorageServicing
    
    init(networkingClient: FPNetworkingClient, storage: any FPTextStorageServicing) {
        self.networkingClient = networkingClient
        self.storage = storage
    }
    
}


extension FPIdentitySessionService {
    
    
    /// Invokes a network call to exchange the authentication code received post-transition
    /// with access and refresh tokens, and then saves them into ``storage``.
    /// 
    /// ## Throws
    /// - ``FPError/EMPTY_ARGUMENT`` when the server supplies an empty value where expected otherwise.
    /// - ``FPError/FORBIDDEN`` when the server returns a forbidden response.
    /// - ``FPError/UNEXPECTED_RESPONSE`` when the server returns an undocumented response.
    /// - ``FPError/UNLOADED_ENTRY`` when the ``authenticationCode`` is nil.
    /// - ``FPError/UNREACHABLE`` when the network is unreachable, request times out, or the server is unreachable.
    func exhangeCodeForTokensAndSaveThem() async -> Result<Void, FPError> {
        guard let authenticationCode else { return .failure(.UNLOADED_ENTRY) }
        
        do {
            let response = try await networkingClient.exchangeAuthenticationCodeForAccessAndRefreshTokens(.init(
                headers: .init(
                    accept: [.init(contentType: .json)]
                ),
                body: .json(.init(
                    authentication_code: authenticationCode,
                    grant_type: "authentication_code"
                ))
            ))
            switch response {
                case .ok(let output):
                    return handle(exchangeAuthCodeResponse: output)
                case .forbidden:
                    throw FPError.FORBIDDEN
                case .undocumented(statusCode: let code, let payload):
                    FPLogger.log(tag: .error, "\(code) - \(payload)")
                    return .failure(.UNEXPECTED_RESPONSE)
            }
            
        } catch {
            return .failure(.UNREACHABLE)
        }
    }
    
    
    /// Invokes a network call that renews ``accessToken`` by passing the ``refreshToken`` over.
    /// The expected response should contain a new access token, that is saved into ``storage``. 
    /// In case where a new refresh token is issued, the new invalidates the old, and it is saved.
    /// 
    /// ## Throws
    /// - ``FPError/EMPTY_ARGUMENT`` when the server supplies an empty value where expected otherwise.
    /// - ``FPError/FORBIDDEN`` when the server returns a forbidden response.
    /// - ``FPError/UNEXPECTED_RESPONSE`` when the server returns an undocumented response.
    /// - ``FPError/UNLOADED_ENTRY`` when the ``refreshToken`` is nil.
    /// - ``FPError/UNREACHABLE`` when the network is unreachable, request times out, or the server is unreachable.
    func refreshAndSaveNewAccessToken() async -> Result<Void, FPError> {
        guard let refreshToken else { return .failure(.UNLOADED_ENTRY) }
        
        do {
            let response = try await networkingClient.refreshAccessTokenWithRefreshToken(.init(
                headers: .init(
                    accept: [.init(contentType: .json)]
                ),
                body: .json(.init(
                    refresh_token: refreshToken
                ))
            ))
            switch response {
                case .ok(let output):
                    return handle(refreshAccessTokenResponse: output)
                case .forbidden:
                    return .failure(.FORBIDDEN)
                case .undocumented(statusCode: let code, let payload):
                    FPLogger.log(tag: .network, "\(code) - \(payload)")
                    return .failure(.UNEXPECTED_RESPONSE)
            }
            
        } catch {
            return .failure(.UNREACHABLE)
        }
    }
    
}

fileprivate extension FPIdentitySessionService {
    
    enum StorageKey: String {
        case authenticationCode
        case accessToken
        case refreshToken
    }
    
    func handle(refreshAccessTokenResponse response: Operations.refreshAccessTokenWithRefreshToken.Output.Ok) -> Result<Void, FPError> {
        switch response.body {
            case .json(let jsonBody):
                guard let accessToken = jsonBody.data?.access_token else { return .failure(.EMPTY_ARGUMENT) }
                
                self.accessToken = accessToken
                switch self.storage.place(for: StorageKey.accessToken.rawValue, data: accessToken) {
                    case .failure(let error): return .failure(error)
                    case .success: return .success(())
                }
        }
    }
    
    func handle(exchangeAuthCodeResponse response: Operations.exchangeAuthenticationCodeForAccessAndRefreshTokens.Output.Ok) -> Result<Void, FPError> {
        switch response.body {
            case .json(let jsonBody):
                guard let accessToken = jsonBody.data?.access_token else { return .failure(.EMPTY_ARGUMENT) }
                
                self.accessToken = accessToken
                switch self.storage.place(for: StorageKey.accessToken.rawValue, data: accessToken) {
                    case .failure(let error): return .failure(error)
                    case .success: break
                }
                
                // When the `refreshToken` argument is supplied (not nil), it means the old refToken
                // is valid no more; and you've got to use the new value from here onwards.
                guard let refreshToken = jsonBody.data?.refresh_token else { return .success(()) }
                
                self.refreshToken = refreshToken
                switch self.storage.place(for: StorageKey.refreshToken.rawValue, data: refreshToken) {
                    case .failure(let error): return .failure(error)
                    case .success: return .success(())
                }
        }
    }
    
}
