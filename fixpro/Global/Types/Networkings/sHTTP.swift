import Foundation

internal struct VinHTTP {
    
    enum Method : String {
        case GET, PATCH, POST, PUT, DELETE
    }
    
}


extension VinHTTP {
    
    struct Parameter {
        let key   : String
        let value : String
        
        struct Encoder {
            public init () {}
            
            public func encodeParameters ( for urlRequest: inout URLRequest, with parameters: [Parameter] ) throws {
                guard let url = urlRequest.url else { throw ResponseError.noURL }
                
                if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
                    urlComponents.queryItems = [URLQueryItem]()
                    for param in parameters {
                        let queryItem = URLQueryItem(name: param.key, value: "\(param.value)")
                        urlComponents.queryItems?.append(queryItem)
                    }
                    urlRequest.url = urlComponents.url
                }
            }
        }
    }
    
}


extension VinHTTP {
    
    enum Header {
        case accept          (MediaType)
        case acceptCharset   (String)
        case acceptEncoding  (String)
        case acceptLanguage  (String)
        case authorization   (AuthorizationType)
        case cacheControl    (String)
        case contentLength   (String)
        case contentType     (MediaType)
        case cookie          (String)
        case host            (String)
        case ifModifiedSince (String)
        case ifNoneMatch     (String)
        case origin          (String)
        case referer         (String)
        case userAgent       (String)
        case custom          (key: String, value: String)
        
        var key: String {
            switch self {
                case .accept             : return "Accept"
                case .acceptCharset      : return "Accept-Charset"
                case .acceptEncoding     : return "Accept-Encoding"
                case .acceptLanguage     : return "Accept-Language"
                case .authorization      : return "Authorization"
                case .cacheControl       : return "Cache-Control"
                case .contentLength      : return "Content-Length"
                case .contentType        : return "Content-Type"
                case .cookie             : return "Cookie"
                case .host               : return "Host"
                case .ifModifiedSince    : return "If-Modified-Since"
                case .ifNoneMatch        : return "If-None-Match"
                case .origin             : return "Origin"
                case .referer            : return "Referer"
                case .userAgent          : return "User-Agent"
                case .custom(let key, _) : return key
            }
        }
        
        var value: String {
            switch self {
                case .accept(let accept)                : return accept.value
                case .acceptCharset(let value)          : return value
                case .acceptEncoding(let value)         : return value
                case .acceptLanguage(let value)         : return value
                case .authorization(let authentication) : return authentication.value
                case .cacheControl(let value)           : return value
                case .contentLength(let value)          : return value
                case .contentType(let contentType)      : return contentType.value
                case .cookie(let value)                 : return value
                case .host(let value)                   : return value
                case .ifModifiedSince(let value)        : return value
                case .ifNoneMatch(let value)            : return value
                case .origin(let value)                 : return value
                case .referer(let value)                : return value
                case .userAgent(let value)              : return value
                case .custom(_, let value)              : return value
            }
        }
        
        var unwrapped: (Dictionary<String, Any>.Key, Dictionary<String, Any>.Value) {
            (self.key, self.value)
        }
    }
    
}


extension VinHTTP {
    
    enum ResponseError : Error {
        case unknown
        case noURL
        case couldNotParse
        case invalidError
        case noData
        case noResponse
        case requestFailed(Error)
        case noRequest
        case noHTTPURLResponse
        
        // Successful Responses (200-299)
        case ok
        
        // Redirection Messages (300-399)
        case multipleChoices, movedPermanently, found, seeOther, notModified, useProxy, temporaryRedirect, permanentRedirect
        
        // Client Errors (400-499)
        case badRequest, unauthorized, paymentRequired, forbidden, notFound, methodNotAllowed, notAcceptable, proxyAuthenticationRequired, requestTimeout, conflict, gone, lengthRequired, preconditionFailed, payloadTooLarge, uriTooLong, unsupportedMediaType, rangeNotSatisfiable, expectationFailed, imATeapot, misdirectedRequest, unprocessableEntity, locked, failedDependency, tooEarly, upgradeRequired, preconditionRequired, tooManyRequests, requestHeaderFieldsTooLarge, unavailableForLegalReasons
        
        // Server Errors (500-599)
        case internalServerError, notImplemented, badGateway, serviceUnavailable, gatewayTimeout, httpVersionNotSupported, variantAlsoNegotiates, insufficientStorage, loopDetected, notExtended, networkAuthenticationRequired
    }
    
    public enum MediaType {
        case json
        case xml
        case formUrlEncoded
        case custon(String)
        
        var value: String {
            switch self {
                case .json              : return "application/json"
                case .xml               : return "application/xml"
                case .formUrlEncoded    : return "application/x-www-form-urlencoded"
                case .custon(let value) : return value
            }
        }
    }
    
    public enum AuthorizationType {
        case bearer(String)
        case custom(String)
        
        var value: String {
            switch self {
                case .bearer(let value) : return "Bearer \(value)"
                case .custom(let value) : return value
            }
        }
    }
    
    struct HeaderEncoder {
        public init () {}
        
        public func encodeHeaders ( for urlRequest: inout URLRequest, with headers: [Header] ) {
            for header in headers {
                urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }
    }
    
}
