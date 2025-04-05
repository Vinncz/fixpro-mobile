import OpenAPIRuntime
import OpenAPIURLSession

class DepFPSessionCredentialsManagerService: DepFPSessionCredentialsManaging {
    
    private let storingService: DepFPSessionCredentialsStoring
    private let networkingClient: Client
    
    init(storingService: DepFPSessionCredentialsStoring, networkingClient: Client) {
        self.storingService = storingService
        self.networkingClient = networkingClient
    }
    
}


extension DepFPSessionCredentialsManagerService {
    
    func exchangeAndSaveAccessAndRefreshTokens(fromAuthorizationCode authCode: String) throws {
        Task {
            let response = try await networkingClient.exchangeAuthenticationCodeForAccessAndRefreshTokens(
                .init(
                    headers: .init(
                        accept: [.init(contentType: .json)]
                    ),
                    body: .json(.init(
                        authentication_code: authCode, 
                        grant_type: "authorization_code"
                    ))
                )
            )
            
            switch response {
                case .ok(let output):
                    switch output.body {
                        case .json(let jsonBody):
                            guard
                                let accessToken = jsonBody.data?.access_token,
                                let refreshToken = jsonBody.data?.refresh_token
                            else { 
                                throw FPError.ILLEGAL_ARGUMENT 
                            }
                            
                            try storingService.save(accessToken: accessToken)
                            try storingService.save(refreshToken: refreshToken)
                            
                            try storingService.populateAccessToken()
                            try storingService.populateRefreshToken()
                    }
                case .forbidden(let output):
                    throw FPError.FORBIDDEN
                default:
                    break
            }
        }
    }
    
    func renewAndSaveAccessToken(fromRefreshToken refreshToken: String) throws {
        Task {
            let response = try await networkingClient.refreshAccessTokenWithRefreshToken(
                .init(
                    headers: .init(
                        accept: [.init(contentType: .json)]
                    ),
                    body: .json(.init(
                        refresh_token: refreshToken
                    ))
                )
            )
            
            switch response {
                case .ok(let output):
                    switch output.body {
                        case .json(let jsonBody):
                            guard
                                let accesToken = jsonBody.data?.access_token
                            else { throw FPError.ILLEGAL_ARGUMENT }
                            
                            try storingService.save(accessToken: accesToken)
                    }
                default:
                    break
            }
        }
    }
    
}
