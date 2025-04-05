import RIBs
import RxSwift
import UIKit


/// Collection of methods which ``MemberScopedViewController`` can invoke, to perform business logic.
///
/// The `PresentableListener` protocol is responsible to bridge UI events to business logic.  
/// When an interaction with the UI is performed (e.g., pressed a button), ``MemberScopedViewController`` **MAY**
/// call method(s) declared here to notify the `Interactor` to perform any associated logics.
///
/// Conformance of this protocol is **EXCLUSIVE** to ``MemberScopedInteractor`` (internal use).
/// ``MemberScopedViewController``, in turn, can invoke methods declared in this protocol 
/// via its ``MemberScopedViewController/presentableListener`` attribute.
protocol MemberScopedPresentableListener: AnyObject {}


/// The UI of `MemberScopedRIB`.
final class MemberScopedViewController: UIViewController, MemberScopedPresentable, MemberScopedViewControllable {
    
    
    /// The reference to ``MemberScopedInteractor``.
    /// 
    /// The word 'presentableListener' is a convention used in RIBs, which refer to the `Interactor`
    /// who reacts to UI events from their descendants. (It 'listens' to them).
    weak var presentableListener: MemberScopedPresentableListener?
    
}


/// Extension to conform ``MemberScopedViewController`` with other RIBs' `ViewControllable` protocols.
/// By conforming to them, you allow for ``MemberScopedViewController`` to be manipulated by their respective `Router`.
extension MemberScopedViewController {}
