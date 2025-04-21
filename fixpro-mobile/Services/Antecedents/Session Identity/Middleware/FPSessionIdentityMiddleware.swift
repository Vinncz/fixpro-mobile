import Foundation
import HTTPTypes
import OpenAPIRuntime
import VinUtility



/// Middleware that injects an `Authorization` header to an HTTP request.
final class FPSessionIdentityMiddleware: ClientMiddleware {
    
    
    private let storage: FPSessionIdentityServicing
    
    
    init(storage: FPSessionIdentityServicing) {
        self.storage = storage
    }
    
    
    /// Invoked for every outbound requests.
    func intercept (
        _   request : HTTPRequest, 
        body        : HTTPBody?, 
        baseURL     : URL, 
        operationID : String, 
        next        : (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var outboundRequest = request
        let token = await storage.accessToken
        
        outboundRequest.headerFields[.authorization] = "Bearer \(token ?? "")"
        return try await next(outboundRequest, body, baseURL)
    }
    
}
