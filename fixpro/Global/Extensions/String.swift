import Foundation

extension String {
    
    static let EMPTY = ""
    
    static let ENDPOINT = FPKeychainQueristService().retrieve(for: "ASJBODVFBOSDBVOUSDYV").get(or: "")
    
}
