import RIBs
import RxSwift
import UIKit


/// Collection of methods which ``InboxViewController`` can invoke, to perform business logic.
///
/// The `PresentableListener` protocol is responsible to bridge UI events to business logic.  
/// When an interaction with the UI is performed (e.g., pressed a button), ``InboxViewController`` **MAY**
/// call method(s) declared here to notify the `Interactor` to perform any associated logics.
///
/// Conformance of this protocol is **EXCLUSIVE** to ``InboxInteractor`` (internal use).
/// ``InboxViewController``, in turn, can invoke methods declared in this protocol 
/// via its ``InboxViewController/presentableListener`` attribute.
protocol InboxPresentableListener: AnyObject {}


/// The UI of `InboxRIB`.
final class InboxViewController: UIViewController, InboxPresentable, InboxViewControllable {
    
    
    /// The reference to ``InboxInteractor``.
    /// 
    /// The word 'presentableListener' is a convention used in RIBs, which refer to the `Interactor`
    /// who reacts to UI events from their descendants. (It 'listens' to them).
    weak var presentableListener: InboxPresentableListener?
    
}


/// Extension to conform ``InboxViewController`` with other RIBs' `ViewControllable` protocols.
/// By conforming to them, you allow for ``InboxViewController`` to be manipulated by their respective `Router`.
extension InboxViewController {}


#Preview {
    InboxViewController()
}
