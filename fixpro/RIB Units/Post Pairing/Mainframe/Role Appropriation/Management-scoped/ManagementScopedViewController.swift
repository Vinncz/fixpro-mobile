import RIBs
import RxSwift
import UIKit


/// Collection of methods which ``ManagementScopedViewController`` can invoke, to perform business logic.
///
/// The `PresentableListener` protocol is responsible to bridge UI events to business logic.  
/// When an interaction with the UI is performed (e.g., pressed a button), ``ManagementScopedViewController`` **MAY**
/// call method(s) declared here to notify the `Interactor` to perform any associated logics.
///
/// Conformance of this protocol is **EXCLUSIVE** to ``ManagementScopedInteractor`` (internal use).
/// ``ManagementScopedViewController``, in turn, can invoke methods declared in this protocol 
/// via its ``ManagementScopedViewController/presentableListener`` attribute.
protocol ManagementScopedPresentableListener: AnyObject {}


/// The UI of `ManagementScopedRIB`.
final class ManagementScopedViewController: UIViewController, ManagementScopedPresentable, ManagementScopedViewControllable {
    
    
    /// The reference to ``ManagementScopedInteractor``.
    /// 
    /// The word 'presentableListener' is a convention used in RIBs, which refer to the `Interactor`
    /// who reacts to UI events from their descendants. (It 'listens' to them).
    weak var presentableListener: ManagementScopedPresentableListener?
    
}


/// Extension to conform ``ManagementScopedViewController`` with other RIBs' `ViewControllable` protocols.
/// By conforming to them, you allow for ``ManagementScopedViewController`` to be manipulated by their respective `Router`.
extension ManagementScopedViewController {}
