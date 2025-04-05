import Foundation
import Security


/// Queries from and to the Apple Keychain.
class FPKeychainQueristService: FPService {}


extension FPKeychainQueristService: RetrieverQuerist {
    
    typealias RetrieverReturnValue = String
    
    func check(for subject: String) -> Result<Bool, FPError> {
        FPLogger.log("Checking for \(subject)")
        
        let query = SecureQuery()
            .RW_OR_keyClass(.genericPassword)
            .OW_OR_keyOwner(subject)
            .RW_RR_RD_applicationTag(subject)
            .OR_returnData()
        
        var keyData: CFTypeRef?
        let status = SecItemCopyMatching(query.unwrapped(), &keyData)
        
        guard status == errSecSuccess else {
            FPLogger.log(tag: .error, SecCopyErrorMessageString(status, nil) as Any)
            return .failure(.MISSING_ENTRY)
        }
        
        return .success(true)
    }
    
    func retrieve(for subject: String, limit: Int = 1) -> Result<String, FPError> {
        FPLogger.log("Retrieving for \(subject)")
        
        let query = SecureQuery()
            .RW_OR_keyClass(.genericPassword)
            .OW_OR_keyOwner(subject)
            .OR_limit(limit)
            .OR_returnData()
        
        var keyData: CFTypeRef?
        let status = SecItemCopyMatching(query.unwrapped(), &keyData)
        
        guard status == errSecSuccess, let data = keyData as? Data, let val = String(data: data, encoding: .utf8) else {
            FPLogger.log(tag: .error, SecCopyErrorMessageString(status, nil) as Any)
            return .failure(.MISSING_ENTRY)
        }
        
        return .success(val)
    }
    
}


extension FPKeychainQueristService: PlacerQuerist {
    
    typealias ReturnValue = Bool
    
    @discardableResult
    func place(for subject: String, data: Data) -> Result<Bool, FPError> {
        FPLogger.log("Placing for \(subject)")
        
        let query = SecureQuery()
            .RW_IR_ID_valueData(data)
            .RW_OR_keyClass(.genericPassword)
            .OW_OR_keyOwner(subject)
            .write(kSecAttrAccessible, kSecAttrAccessibleWhenUnlocked)
        
        let status = SecItemAdd(query.unwrapped(), nil)
        switch status {
            case errSecSuccess:
                return .success(true)
            case errSecDuplicateItem:
                return .failure(.DUPLICATE_ENTRY)
            default:
                break
        }
        
        FPLogger.log(tag: .error, SecCopyErrorMessageString(status, nil) as Any)
        return .failure(.UNKNOWN)
    }
    
}


extension FPKeychainQueristService: RemoverQuerist {
    
    typealias RemoverReturnValue = Bool
    
    @discardableResult
    func remove(for subject: String) -> Result<Bool, FPError> {
        FPLogger.log("Removing for \(subject)")
        
        let query = SecureQuery()
            .OW_OR_keyOwner(subject)
            .RW_OR_keyClass(.genericPassword)
        
        let status = SecItemDelete(query.unwrapped())
        switch status {
            case errSecSuccess:
                return .success(true)
            default: 
                break
        }
        
        FPLogger.log(tag: .error, SecCopyErrorMessageString(status, nil) as Any)
        return .failure(.UNKNOWN)
    }
    
}
