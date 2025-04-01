import Foundation
import os
import Security

func convertKeyToData ( from inputKey: SecKey ) -> Result<Data, Error> {
    
    var error: Unmanaged<CFError>?
    let externalRep = SecKeyCopyExternalRepresentation(inputKey, &error)
    
    if let externalRep {
        return .success(externalRep as Data)
        
    } else if let error = error?.takeRetainedValue() {
        FPLogger.log(tag: .error, "\(#function + error.localizedDescription)")
        return .failure(error)
        
    } else {
        return .failure(FPError.UNKNOWN)
        
    }
    
}
