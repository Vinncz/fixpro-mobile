import Foundation
import os
import Security

func derivePublicKey ( from inputPrivateKey: SecKey ) -> Result<SecKey, FPError> {
    let publicKey = SecKeyCopyPublicKey(inputPrivateKey)
    
    if let publicKey {
        return .success(publicKey)
    } else {
        FPLogger.log(tag: .error, "Unable to derive public key from its private counterpart.")
        return .failure(.DERIVATION_FAILURE)
    }
}
