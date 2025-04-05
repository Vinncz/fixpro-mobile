import RIBs
import RxSwift
import UIKit


/// Collection of methods which ``RootViewController`` can invoke, to perform business logic.
///
/// The `PresentableListener` protocol is responsible to bridge UI events to business logic.  
/// When an interaction with the UI is performed (e.g., pressed a button), ``RootViewController`` **MAY**
/// call method(s) declared here to notify the `Interactor` to perform any associated logics.
///
/// Conformance of this protocol is **EXCLUSIVE** to ``RootInteractor`` (internal use).
/// ``RootViewController``, in turn, can invoke methods declared in this protocol 
/// via its ``RootViewController/presentableListener`` attribute.
protocol RootPresentableListener: AnyObject {}


/// The UI of `RootRIB`.
final class RootViewController: UIViewController, RootPresentable, RootViewControllable {
    
    
    /// The reference to ``RootInteractor``.
    /// 
    /// The word 'presentableListener' is a convention used in RIBs, which refer to the `Interactor`
    /// who reacts to UI events from their descendants. (It 'listens' to them).
    weak var presentableListener: RootPresentableListener?
    
    
    /// The reference of the active (presented) flow.
    /// 
    /// A 'flow' is a string of views managed by this RIB's descendants.
    private var activeFlow: ViewControllable?
    
    
    /// Transitions between flows.
    func transitionFlow (to newFlow: any ViewControllable) {
        if let activeFlow {
            cleanupFlow(from: activeFlow)
            self.activeFlow = nil
        }
        
        self.activeFlow = newFlow
        
        // Note to self: -- For full-screen integration, use:
        self.addChild(newFlow.uiviewController)
        self.view.addSubview(newFlow.uiviewController.view)
        newFlow.uiviewController.didMove(toParent: self)
        
        // For small plug-ins, using addSubview(_:) should suffice.
    }
    
    
    /// Performs cleanup after a flow transition happened.
    func cleanupFlow (from oldFlow: ViewControllable) {
        activeFlow = nil
        oldFlow.uiviewController.view.removeFromSuperview()
        oldFlow.uiviewController.removeFromParent()
    }
    
}


/// Extension to conform ``RootViewController`` with other RIBs' `ViewControllable` protocols.
/// By conforming to them, you allow for ``RootViewController`` to be manipulated by their respective `Router`.
extension RootViewController: MainframeViewControllable {}
