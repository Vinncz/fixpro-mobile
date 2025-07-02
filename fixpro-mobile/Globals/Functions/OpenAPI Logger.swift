import Foundation


func print(urlRequest request: URLRequest) {
    print("➡️ URLRequest")
    print("Method: \(request.httpMethod ?? "<no method>")")
    print("URL: \(request.url?.absoluteString ?? "<no url>")")

    // Headers
    if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
        print("Headers:")
        for (key, value) in headers {
            print("  \(key): \(value)")
        }
    } else {
        print("Headers: <none>")
    }

    // Body
    if let body = request.httpBody {
        if let bodyString = String(data: body, encoding: .utf8) {
            print("Body:\n\(bodyString)")
        } else {
            print("Body: <binary or non-utf8>")
        }
    } else {
        print("Body: <none>")
    }

    print("~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~")
}
