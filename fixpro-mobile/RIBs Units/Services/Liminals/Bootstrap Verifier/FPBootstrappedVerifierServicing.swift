import Foundation
import VinUtility



protocol FPBootstrappedVerifierServicing: VUStatelessServicing {
    
    
    func verifyBootstrapped() -> Result<(sessionIdentity: FPSessionIdentityServiceSnapshot, networkingClient: FPNetworkingClientSnapshot), FPError>
    
}
