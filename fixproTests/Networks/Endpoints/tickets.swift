import Testing
import OpenAPIRuntime
import OpenAPIURLSession
@testable import fixpro

struct TicketsEndpointTests {
    
    private let client = Client(
        serverURL: try! Servers.PairedAreaAddress.url(), 
        transport: URLSessionTransport()
    )
    
    @Test func getTickets() async throws {
        do {
            let response = try await client.getTickets(.init(headers: .init(accept: [.init(contentType: .json)])))
            FPLogger.log(response)
        } catch {
            FPLogger.log(tag: .error, error)
        }
    }
    
    @Test func raiseTicket() async throws {
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
