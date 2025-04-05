import RIBs
import RxSwift
import UIKit


/// Collection of methods which ``PairViewController`` can invoke, to perform business logic.
///
/// The `PresentableListener` protocol is responsible to bridge UI events to business logic.  
/// When an interaction with the UI is performed (e.g., pressed a button), ``PairViewController`` **MAY**
/// call method(s) declared here to notify the `Interactor` to perform any associated logics.
///
/// Conformance of this protocol is **EXCLUSIVE** to ``PairInteractor`` (internal use).
/// ``PairViewController``, in turn, can invoke methods declared in this protocol 
/// via its ``PairViewController/presentableListener`` attribute.
protocol PairPresentableListener: AnyObject {}


/// The UI of `PairRIB`.
final class PairViewController: UINavigationController, PairPresentable, PairViewControllable {
    
    
    /// The reference to ``PairInteractor``.
    /// 
    /// The word 'presentableListener' is a convention used in RIBs, which refer to the `Interactor`
    /// who reacts to UI events from their descendants. (It 'listens' to them).
    weak var presentableListener: PairPresentableListener?
    
    
    override func viewDidLoad () {
        self.modalPresentationStyle = .fullScreen
        view.backgroundColor = .systemBackground
        self.delegate = self
    }
    
}

extension PairViewController: UINavigationControllerDelegate {
    
    func navigationController (
        _ navigationController: UINavigationController, 
        didShow viewController: UIViewController, 
        animated: Bool
    ) {
        guard 
            let initialVC = navigationController.transitionCoordinator?.viewController(forKey: .from),
            navigationController.viewControllers.contains(initialVC) == false
        else {
            return
        }
    }
    
}


/// Extension to conform ``PairViewController`` with other RIBs' `ViewControllable` protocols.
/// By conforming to them, you allow for ``PairViewController`` to be manipulated by their respective `Router`.
extension PairViewController {}
