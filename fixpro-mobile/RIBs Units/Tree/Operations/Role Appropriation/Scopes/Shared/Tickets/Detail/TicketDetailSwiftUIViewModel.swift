import Foundation
import Observation



/// Bridges between ``TicketDetailSwiftUIView`` and the ``TicketDetailInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class TicketDetailSwiftUIViewModel {
    
    
    var role: FPTokenRole
    var baseURL: URL?
    var ticket: FPTicketDetail?
    init(role: FPTokenRole) {
        self.role = role
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
