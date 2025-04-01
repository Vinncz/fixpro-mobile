import CryptoKit
import OpenAPIRuntime
import OpenAPIURLSession
import Testing
@testable import fixpro

struct NotificationEndpointTests {
    
    private let client = Client(
        serverURL: try! Servers.PairedAreaAddress.url(), 
        transport: URLSessionTransport()
    )
    
    @Test func getNotificationPairingInformation() async throws {
        do {
            let privateKey = P256.KeyAgreement.PrivateKey()
            let publicKey  = privateKey.publicKey
            let attemptedContact = try await client.getNotificationPairingInformation(
                .init(
                    query: .init(enkey: "\(publicKey)"), 
                    headers: .init(accept: [.init(contentType: .json)])
                )
            )
            
            switch attemptedContact {
                case .ok(let response):
                    switch response.body {
                        case .json(let body):
                            FPLogger.log(body.data)
                    }
                case .undocumented(statusCode: let code, let payload):
                    switch code {
                        case 200..<300:
                            break
                        case 400..<500:
                            break
                        default:
                            break
                            
                    }
            }
        } catch {
            FPLogger.log(tag: .error, error)
        }
    }
    
    @Test func putFCMAddressToken() async throws {
        do {
            let response = try await client.raiseTicket(.init(
                headers:
                    .init(accept: [.init(contentType: .json)]),
                body:
                    .json(.init(
                        issue_type: .init(stringLiteral: "Plumbing"),
                        response_level: .init(stringLiteral: "Urgent"),
                        stated_issue: .init(stringLiteral: "There was none"),
                        location: .init(
                            stated_location: "Third floor", 
                            gps_location: .init(
                                latitude: 0.0,
                                longitude: 0.0
                            )
                        ),
                        supportive_documents: []
                    ))
            ))
            FPLogger.log(response)
        } catch {
            FPLogger.log(tag: .error, error)
        }
    }
    
}
