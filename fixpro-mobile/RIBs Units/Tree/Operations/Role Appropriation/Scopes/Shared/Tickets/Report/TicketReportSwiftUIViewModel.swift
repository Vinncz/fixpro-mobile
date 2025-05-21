import Foundation
import Observation



/// Bridges between ``TicketReportSwiftUIView`` and the ``TicketReportInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class TicketReportSwiftUIViewModel {
    
    
    var urlToReport: URL
    
    
    var didIntendToDismiss: (() -> Void)?
    
    
    var didIntendToDownload: (() -> Void)?
    
    
    init(urlToReport: URL, didIntendToDismiss: (() -> Void)? = nil, didIntendToDownload: (() -> Void)? = nil) {
        self.urlToReport = urlToReport
        self.didIntendToDismiss = didIntendToDismiss
        self.didIntendToDownload = didIntendToDownload
    }
    
}
