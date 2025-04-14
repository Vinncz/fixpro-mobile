import OpenAPIRuntime
import OpenAPIURLSession
import Foundation
import VinUtility

struct FPNetworkingClient {
    
    var gateway: Client
    var endpoint: URL
    
    init(endpoint: URL) {
        self.gateway = Client(serverURL: endpoint, transport: URLSessionTransport())
        self.endpoint = endpoint
    }
    
}
