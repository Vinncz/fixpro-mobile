import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

extension Servers {
    
    enum PairedAreaAddress {
        internal static func url() throws -> Foundation.URL {
            try Foundation.URL(
                validatingOpenAPIServerURL: "http://192.168.1.3:9196"
            )
        }
    }
    
}
