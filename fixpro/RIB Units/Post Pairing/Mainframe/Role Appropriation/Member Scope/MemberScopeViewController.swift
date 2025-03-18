import RIBs
import RxSwift
import UIKit


/// Collection of methods which ``MemberScopeViewController`` can invoke, to perform business logic.
///
/// The `PresentableListener` protocol is responsible to bridge UI events to business logic.  
/// When an interaction with the UI is performed (e.g., pressed a button), ``MemberScopeViewController`` **MAY**
/// call method(s) declared here to notify the `Interactor` to perform any associated logics.
///
/// Conformance of this protocol is **EXCLUSIVE** to ``MemberScopeInteractor`` (internal use).
/// ``MemberScopeViewController``, in turn, can invoke methods declared in this protocol 
/// via its ``MemberScopeViewController/presentableListener`` attribute.
protocol MemberScopePresentableListener: AnyObject {}


/// The UI of `MemberScopeRIB`.
final class MemberScopeViewController: UIViewController, MemberScopePresentable, MemberScopeViewControllable {
    
    
    /// The reference to ``MemberScopeInteractor``.
    /// 
    /// The word 'presentableListener' is a convention used in RIBs, which refer to the `Interactor`
    /// who reacts to UI events from their descendants. (It 'listens' to them).
    weak var presentableListener: MemberScopePresentableListener?
    
    
    override func viewDidLoad() {
        view.backgroundColor = .systemPink
    }
    
}


/// Extension to conform ``MemberScopeViewController`` with other RIBs' `ViewControllable` protocols.
/// By conforming to them, you allow for ``MemberScopeViewController`` to be manipulated by their respective `Router`.
extension MemberScopeViewController {}
