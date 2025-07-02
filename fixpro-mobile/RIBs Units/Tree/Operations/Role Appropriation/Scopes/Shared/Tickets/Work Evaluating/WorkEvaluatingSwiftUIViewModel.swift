import Foundation
import Observation



/// Bridges between ``WorkEvaluatingSwiftUIView`` and the ``WorkEvaluatingInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class WorkEvaluatingSwiftUIViewModel {
    
    
    var component: WorkEvaluatingComponent
    
    
    var ticket: FPTicketDetail
    
    
    var didIntendToCancel: (() -> Void)?
    
    
    var didIntendToEvaluate: (() async throws -> Void)?
    
    
    init(ticket: FPTicketDetail, component: WorkEvaluatingComponent) {
        self.ticket = ticket
        self.component = component
    }
    
    
    var resolve: EvaluationResolve = .Select
    
    
    var requireOwnerEvaluation: Bool = false
    
    
    var remarks: String = .EMPTY
    
    
    var supportiveDocuments: [URL] = []
    
}



enum EvaluationResolve: String, CaseIterable, Identifiable {
    case Select
    case Approved
    case Rejected
    
    var id: Self { self }
}
