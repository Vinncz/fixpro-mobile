import Foundation



protocol FPSessionBootstrapping {
    
    
    func from(authCode: String, networkingClient: FPNetworkingClient) async throws -> FPSessionIdentityServicing
    
    
    func from(snapshot: FPSessionIdentityServiceSnapshot) -> FPSessionIdentityServicing
    
}
