import Foundation
import VinUtility



struct AreaJoinCode: Codable {
    
    
    let endpoint: URL
    
    
    let referralTrackingIdentifier: String
    
    
    private init(endpoint: URL, referralTrackingIdentifier: String) {
        self.endpoint = endpoint
        self.referralTrackingIdentifier = referralTrackingIdentifier
    }
    
}

extension AreaJoinCode {
    
    
    static func make(fromJsonString json: String) -> Result<AreaJoinCode, FPError> {
        do {
            guard let data = json.data(using: .utf8) else { throw FPError.MALFORMED }
            let result = try JSONDecoder().decode(AreaJoinCode.self, from: data)
            
            return .success(.init(
                endpoint: result.endpoint, 
                referralTrackingIdentifier: result.referralTrackingIdentifier
            ))
            
        } catch let error as FPError {
            VULogger.log(tag: .critical, "Caught here: \(json)")
            return .failure(error)
            
        } catch let error as DecodingError {
            VULogger.log(tag: .critical, "Caught here: \(json)")
            VULogger.log(tag: .error, error)
            return .failure(.MALFORMED)
            
        } catch {
            VULogger.log(tag: .critical, "Caught here: \(json)")
            VULogger.log(tag: .error, error)
            return .failure(.UNKNOWN)
            
        }
    }
    
}
