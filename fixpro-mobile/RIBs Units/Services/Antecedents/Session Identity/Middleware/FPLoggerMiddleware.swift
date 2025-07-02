import Foundation
import HTTPTypes
import OpenAPIRuntime
import VinUtility



final class FPLoggerMiddleware: ClientMiddleware {
    
    
    
    /// Intercepts an outgoing HTTP request and an incoming HTTP response.
    func intercept (
        _   request : HTTPRequest, 
        body        : HTTPBody?, 
        baseURL     : URL, 
        operationID : String, 
        next        : @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        
        
        // MARK: -- Request
        
        let requestBodyCopy1: Data? = try await copy(body: body)
        let requestBodyDigest: String = requestBodyCopy1.flatMap { String(data: $0, encoding: .utf8) } ?? "<non-utf8 or empty>"

        
        var requestHeaderDigest: String = ""
        request.headerFields.forEach { field in
            requestHeaderDigest += "\(field.name.canonicalName.fixedWidth(16)): \(field.value)\n"
        }
        
        
        VULogger.log(tag: .network, 
            """
            OUTBOUND REQUEST -- #\(operationID)
            DST: \(baseURL)
            ---------------------
            HEADER:
            \(requestHeaderDigest)
            ---------------------
            BODY:
            \(requestBodyDigest)
            ~~~~~~~~~~~~~~~~~~~~~
            """
        )
        
        
        let requestBodyCopy2: HTTPBody? = requestBodyCopy1.map(HTTPBody.init)
        let (response, responseBody) = try await next(request, requestBodyCopy2, baseURL)
        
        
        // MARK: -- Response
        
        let responseBodyCopy1: Data? = try await copy(body: responseBody)
        var responseBodyDigest: String = ""
        if let responseBodyCopy1 {
            responseBodyDigest = prettyPrint(json: responseBodyCopy1) 
        }
        
        var responseHeaderDigest: String = ""
        
        response.headerFields.forEach { field in
            responseHeaderDigest += "\(field.name.canonicalName.fixedWidth(16)): \(field.value)\n"
        }
        VULogger.log(tag: .network, 
            """
            INBOUND RESPONSE -- #\(operationID)
            CODE: \(response.status.code)
            DST: \(baseURL)
            ---------------------
            HEADER:
            \(responseHeaderDigest)
            ---------------------
            BODY:
            \(responseBodyDigest)
            ~~~~~~~~~~~~~~~~~~~~~
            """
        )
        
        let responseBodyCopy2: HTTPBody? = responseBodyCopy1.map(HTTPBody.init)
        return (response, responseBodyCopy2)
    }
    
    
    private func copy(body: HTTPBody?) async throws -> Data? {
       return if let body {
           try await collectBodyData(body)
       } else {
           nil
       }
    }
    
    
    private func collectBodyData(_ body: HTTPBody) async throws -> Data {
        var collected = Data()
        for try await chunk in body {
            collected.append(contentsOf: chunk)
        }
        
        return collected
    }
    
    
    fileprivate func prettyPrint(json: Data?) -> String {
        do {
            guard let json else { return "" }
            let object = try JSONSerialization.jsonObject(with: json, options: [])
            let prettyData = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])
            return String(decoding: prettyData, as: UTF8.self)
            
        } catch {
            return "<invalid JSON or non-decodable>"
            
        }
    }
    
}



extension String {
    func fixedWidth(_ width: Int, padding: Character = " ") -> String {
        if self.count > width {
            return String(self.prefix(width))
        } else {
            return self.padding(toLength: width, withPad: String(padding), startingAt: 0)
        }
    }
}
