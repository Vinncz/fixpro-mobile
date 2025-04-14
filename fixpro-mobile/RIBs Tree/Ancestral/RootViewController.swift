import Foundation
import RIBs
import RxSwift
import UIKit



/// Contract adhered to by ``RootInteractor``, listing the attributes and/or actions 
/// that ``RootViewController`` is allowed to access or invoke.
protocol RootPresentableListener: AnyObject {}
 
 

/// The visible region of `RootRIB`.
final class RootViewController: UIViewController {
    
    
    /// Reference to ``RootInteractor``.
    weak var presentableListener: RootPresentableListener?
    
    
    /// Reference to the active (presented) `ViewControllable`.
    var activeFlow: (any ViewControllable)?
    
    
    /// Customization point that is invoked after self enters the view hierarchy.
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}



/// Conformance to the ``RootViewControllable`` protocol.
/// Contains everything accessible or invokable by ``RootRouter``.
extension RootViewController: RootViewControllable {
    
    
    /// Inserts the given `ViewControllable` into the view hierarchy.
    /// - Parameter newFlow: The `ViewControllable` to be inserted.
    /// - Parameter completion: A closure to be executed after the insertion is complete.
    /// 
    /// The default implementation of this method adds the new `ViewControllable` as a child view controller
    /// and adds its view as a subview of the current view controller's view.
    /// - Note: The default implementation of this method REMOVES the previous `ViewControllable` from the view hierarchy.
    func transition(to newFlow: any ViewControllable, completion: (() -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.activeFlow?.uiviewController.view.removeFromSuperview()
            self.activeFlow?.uiviewController.removeFromParent()
            
            self.activeFlow = newFlow
            
            self.addChild(newFlow.uiviewController)
            self.view.addSubview(newFlow.uiviewController.view)
            newFlow.uiviewController.didMove(toParent: self)
            
            completion?()
        }
    }
    
    
    /// Clears any `ViewControllable` from the view hierarchy.
    /// - Parameter completion: A closure to be executed after the cleanup is complete.
    /// 
    /// The default implementation of this method removes the current `ViewControllable` from the view hierarchy.
    func cleanUp(completion: (() -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.activeFlow?.uiviewController.view.removeFromSuperview()
            self.activeFlow?.uiviewController.removeFromParent()
            
            self.activeFlow = nil
            
            completion?()
        }
    }
    
}



/// Conformance to the ``OperationalViewControllable`` protocol.
/// Contains everything accessible or ivokable by ``OperationalRouter``.
extension RootViewController: OperationsViewControllable {}



/// Conformance to the ``RootPresentable`` protocol.
/// Contains everything accessible or invokable by ``RootInteractor``
extension RootViewController: RootPresentable {}
