import RIBs
import RxSwift
import UIKit


/// Collection of methods which ``CrewScopedViewController`` can invoke, to perform business logic.
///
/// The `PresentableListener` protocol is responsible to bridge UI events to business logic.  
/// When an interaction with the UI is performed (e.g., pressed a button), ``CrewScopedViewController`` **MAY**
/// call method(s) declared here to notify the `Interactor` to perform any associated logics.
///
/// Conformance of this protocol is **EXCLUSIVE** to ``CrewScopedInteractor`` (internal use).
/// ``CrewScopedViewController``, in turn, can invoke methods declared in this protocol 
/// via its ``CrewScopedViewController/presentableListener`` attribute.
protocol CrewScopedPresentableListener: AnyObject {}


/// The UI of `CrewScopedRIB`.
final class CrewScopedViewController: UIViewController, CrewScopedPresentable, CrewScopedViewControllable {
    
    
    /// The reference to ``CrewScopedInteractor``.
    /// 
    /// The word 'presentableListener' is a convention used in RIBs, which refer to the `Interactor`
    /// who reacts to UI events from their descendants. (It 'listens' to them).
    weak var presentableListener: CrewScopedPresentableListener?
    
}


/// Extension to conform ``CrewScopedViewController`` with other RIBs' `ViewControllable` protocols.
/// By conforming to them, you allow for ``CrewScopedViewController`` to be manipulated by their respective `Router`.
extension CrewScopedViewController {}
