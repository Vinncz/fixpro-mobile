import Foundation
import Observation



/// Bridges between ``OperationsSwiftUIView`` and the ``OperationsInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class OperationsSwiftUIViewModel {
    
    enum State {
        case normal(String)
        case failure(String, String, (()->Void))
    }
    
    var state: State = .normal("Wiring up...")
    
    
    var didIntendToLogOut: (()->Void)?
    
}
