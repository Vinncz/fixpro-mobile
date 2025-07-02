import Foundation
import VinUtility
import Observation



/// Bridges between ``TicketDetailSwiftUIView`` and the ``TicketDetailInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class TicketDetailSwiftUIViewModel {
    
    
    var component: TicketDetailComponent
    var role: FPTokenRole
    var baseURL: URL?
    var ticket: FPTicketDetail?
    init(component: TicketDetailComponent) {
        self.role = component.authorizationContext.role
        self.component = component
    }
    
    
    func printViewURLRequest() async -> URLRequest? {
        if let ticket,
            let previewURL = URL(string: "\(baseURL?.absoluteString ?? "")/ticket/\(ticket.id)/print-view") 
        {
            var req = URLRequest(url: previewURL)
            await req.setValue("Bearer \(component.identityService.accessToken ?? "")", forHTTPHeaderField: "Authorization")
            VULogger.log("URLRequest set.", req)
            
            do {
                print("➡️ OUTBOUND REQUEST")
                print(urlRequest: req)

                let (data, response) = try await URLSession.shared.data(for: req)

                if let httpResp = response as? HTTPURLResponse {
                    print("⬅️ INBOUND RESPONSE")
                    print("Status: \(httpResp.statusCode)")

                    print("Headers:")
                    for (key, value) in httpResp.allHeaderFields {
                        print("  \(key): \(value)")
                    }

                    if let bodyText = String(data: data, encoding: .utf8) {
                        print("Body:\n\(bodyText)")
                    } else {
                        print("Body: <binary or non-UTF8>")
                    }

                    print("~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~")
                }
            } catch {
                print("❗️Error sending request: \(error)")
            }
            
            
            return req
        }
        
        return nil
    }
    
    
    // MARK: -- View states
    var shouldShowPrintView: Bool = false
    var shouldShowCancellationAlert: Bool = false
    var shouldShowRejectionAlert: Bool = false
    
    
    // MARK: -- Invokables
    var didIntedToRefresh: (() async throws -> Void)?
    var didTapTicketLog: ((_ log: FPTicketLog)->Void)?
    var didCancelTicket: (() async throws -> Void)?
    var didRejectTicket: ((String, [URL]) async throws -> Void)?
    
}
