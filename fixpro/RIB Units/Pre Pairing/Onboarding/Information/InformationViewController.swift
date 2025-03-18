import RIBs
import RxSwift
import UIKit


/// Collection of methods which ``InformationViewController`` can invoke, to perform business logic.
///
/// The `PresentableListener` protocol is responsible to bridge UI events to business logic.  
/// When an interaction with the UI is performed (e.g., pressed a button), ``InformationViewController`` **MAY**
/// call method(s) declared here to notify the `Interactor` to perform any associated logics.
///
/// Conformance of this protocol is **EXCLUSIVE** to ``InformationInteractor`` (internal use).
/// ``InformationViewController``, in turn, can invoke methods declared in this protocol 
/// via its ``InformationViewController/presentableListener`` attribute.
protocol InformationPresentableListener: AnyObject {}


/// The UI of `InformationRIB`.
final class InformationViewController: UIViewController, InformationPresentable, InformationViewControllable {
    
    
    /// The reference to ``InformationInteractor``.
    /// 
    /// The word 'presentableListener' is a convention used in RIBs, which refer to the `Interactor`
    /// who reacts to UI events from their descendants. (It 'listens' to them).
    weak var presentableListener: InformationPresentableListener?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
    }
    
}


/// Extension to conform ``InformationViewController`` with other RIBs' `ViewControllable` protocols.
/// By conforming to them, you allow for ``InformationViewController`` to be manipulated by their respective `Router`.
extension InformationViewController {}
