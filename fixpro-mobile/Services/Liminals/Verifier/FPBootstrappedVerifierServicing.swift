import Foundation
import VinUtility



protocol FPBootstrappedVerifierServicing: VUStatelessServicing {
    
    
    func verifyBootstrapped() -> Result<(endpoint: URL, refreshToken: String), FPError>
    
}
