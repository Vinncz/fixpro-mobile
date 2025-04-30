import Foundation



final class FPSessionBootstrapper: FPSessionBootstrapping {
    
    
    func from(authCode: String, networkingClient: FPNetworkingClient) async throws -> any FPSessionIdentityServicing {
        try await FPSessionIdentityService.exhangeForTokens(authenticationCode: authCode, networkingClient: networkingClient).get()
    }
    
    
    func from(snapshot: FPSessionIdentityServiceSnapshot) -> any FPSessionIdentityServicing {
        FPSessionIdentityService.boot(fromSnapshot: snapshot).get()
    }
    
}
