import RIBs
import RxSwift
import UIKit


/// Collection of methods which ``OutboundJoinRequestViewController`` can invoke, to perform business logic.
///
/// The `PresentableListener` protocol is responsible to bridge UI events to business logic.  
/// When an interaction with the UI is performed (e.g., pressed a button), ``OutboundJoinRequestViewController`` **MAY**
/// call method(s) declared here to notify the `Interactor` to perform any associated logics.
///
/// Conformance of this protocol is **EXCLUSIVE** to ``OutboundJoinRequestInteractor`` (internal use).
/// ``OutboundJoinRequestViewController``, in turn, can invoke methods declared in this protocol 
/// via its ``OutboundJoinRequestViewController/presentableListener`` attribute.
protocol OutboundJoinRequestPresentableListener: AnyObject {}


/// The UI of `OutboundJoinRequestRIB`.
final class OutboundJoinRequestViewController: UIViewController, OutboundJoinRequestPresentable, OutboundJoinRequestViewControllable {
    
    
    /// The reference to ``OutboundJoinRequestInteractor``.
    /// 
    /// The word 'presentableListener' is a convention used in RIBs, which refer to the `Interactor`
    /// who reacts to UI events from their descendants. (It 'listens' to them).
    weak var presentableListener: OutboundJoinRequestPresentableListener?
    
}


/// Extension to conform ``OutboundJoinRequestViewController`` with other RIBs' `ViewControllable` protocols.
/// By conforming to them, you allow for ``OutboundJoinRequestViewController`` to be manipulated by their respective `Router`.
extension OutboundJoinRequestViewController {}
