import Foundation
import os
import Security

func derivePublicKey ( from inputPrivateKey: SecKey ) -> (result: SecKey?, fault: FPError?) {
    let publicKey = SecKeyCopyPublicKey(inputPrivateKey)
    
    if let publicKey {
        return (publicKey, nil)
    } else {
        Logger().error("\(#function + String(FPError.OP_FAIL.rawValue))")
        return (nil, .OP_FAIL)
    }
}
