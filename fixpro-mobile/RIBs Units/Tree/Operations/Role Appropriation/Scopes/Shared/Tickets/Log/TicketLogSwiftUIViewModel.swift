import Foundation
import Observation



/// Bridges between ``TicketLogSwiftUIView`` and the ``TicketLogInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class TicketLogSwiftUIViewModel {
    
    
    var log: FPTicketLog
    
    
    var download: (()->Void)?
    
    
    init(log: FPTicketLog) {
        self.log = log
    }
    
}
