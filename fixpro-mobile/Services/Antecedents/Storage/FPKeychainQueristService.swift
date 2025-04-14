import Foundation
import Security
import VinUtility


/// Queries from and to the Apple Keychain.
class FPKeychainQueristService: VUServicing {}


extension FPKeychainQueristService: VURetrieverQuerist {
    
    typealias RetrieverReturnValue = String
    
    func check(for subject: String) -> Result<Bool, FPError> {
        let query = VUSecureQuery()
            .RW_OR_keyClass(.genericPassword)
            .OW_OR_keyOwner(subject)
            .RW_RR_RD_applicationTag(subject)
            .OR_returnData()
        
        var keyData: CFTypeRef?
        let status = SecItemCopyMatching(query.unwrapped(), &keyData)
        
        guard status == errSecSuccess else {
            VULogger.log(tag: .error, "\(subject) is absent.")
            return .failure(.MISSING_ENTRY)
        }
        
        VULogger.log(tag: .success, "\(subject) is present.")
        return .success(true)
    }
    
    func retrieve(for subject: String, limit: Int = 1) -> Result<String, FPError> {
        let query = VUSecureQuery()
            .RW_OR_keyClass(.genericPassword)
            .OW_OR_keyOwner(subject)
            .OR_limit(limit)
            .OR_returnData()
        
        var keyData: CFTypeRef?
        let status = SecItemCopyMatching(query.unwrapped(), &keyData)
        
        guard status == errSecSuccess, let data = keyData as? Data, let val = String(data: data, encoding: .utf8) else {
            VULogger.log(tag: .error, "Did not find \(subject)")
            return .failure(.MISSING_ENTRY)
        }
        
        VULogger.log(tag: .success, "Retrieved for \(subject)")
        return .success(val)
    }
    
}


extension FPKeychainQueristService: VUPlacerQuerist {
    
    typealias ReturnValue = Bool
    
    @discardableResult
    func place(for subject: String, data: Data) -> Result<Bool, FPError> {
        let query = VUSecureQuery()
            .RW_IR_ID_valueData(data)
            .RW_OR_keyClass(.genericPassword)
            .OW_OR_keyOwner(subject)
            .write(kSecAttrAccessible, kSecAttrAccessibleWhenUnlocked)
        
        let status = SecItemAdd(query.unwrapped(), nil)
        switch status {
            case errSecSuccess:
                VULogger.log(tag: .success, "Placed for \(subject)")
                return .success(true)
            case errSecDuplicateItem:
                VULogger.log(tag: .error, "Stopped placement-op before overwriting \(subject)")
                return .failure(.DUPLICATE_ENTRY)
            default:
                break
        }
        
        VULogger.log(tag: .error, "\(subject) -- \(SecCopyErrorMessageString(status, nil) as Any)")
        return .failure(.UNKNOWN)
    }
    
}


extension FPKeychainQueristService: VURemoverQuerist {
    
    typealias RemoverReturnValue = Bool
    
    @discardableResult
    func remove(for subject: String) -> Result<Bool, FPError> {
        let query = VUSecureQuery()
            .OW_OR_keyOwner(subject)
            .RW_OR_keyClass(.genericPassword)
        
        let status = SecItemDelete(query.unwrapped())
        switch status {
            case errSecSuccess:
                VULogger.log(tag: .success, "Removed \(subject)")
                return .success(true)
            default: 
                break
        }
        
        VULogger.log(tag: .error, "\(subject) -- \(SecCopyErrorMessageString(status, nil) as Any)")
        return .failure(.UNKNOWN)
    }
    
}
