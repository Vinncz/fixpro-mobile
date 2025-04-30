import Foundation
import Observation



/// Bridges between ``TicketReportSwiftUIView`` and the ``TicketReportInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class TicketReportSwiftUIViewModel {
    
    
    var urlToReport: URL = URL(string: "localhost:80")!
    
    
    var didIntendToDismiss: (() -> Void)?
    
}
