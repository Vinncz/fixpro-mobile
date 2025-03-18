import Foundation
import os
import Security

func convertKeyToData ( from inputKey: SecKey ) -> (result: Data?, fault: FPError?) {
    
    var error: Unmanaged<CFError>?
    let externalRep = SecKeyCopyExternalRepresentation(inputKey, &error)
    
    if let error = error?.takeRetainedValue() {
        Logger().error("\(#function + error.localizedDescription)")
        return (nil, .OP_FAIL)
    } else {
        return (externalRep as Data?, nil)
    }
    
}
