import RIBs



/// Contract adhered to by ``WorkEvaluatingInteractor``, listing the attributes and/or actions 
/// that ``WorkEvaluatingRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol WorkEvaluatingInteractable: Interactable {
    var router: WorkEvaluatingRouting? { get set }
    var listener: WorkEvaluatingListener? { get set }
}



/// Contract adhered to by ``WorkEvaluatingViewController``, listing the attributes and/or actions
/// that ``WorkEvaluatingRouter`` is allowed to access or invoke.
protocol WorkEvaluatingViewControllable: ViewControllable {
    
    
    /// Inserts the given `ViewControllable` into the view hierarchy.
    /// - Parameter newFlow: The `ViewControllable` to be inserted.
    /// - Parameter completion: A closure to be executed after the insertion is complete.
    /// 
    /// The default implementation of this method adds the new `ViewControllable` as a child view controller
    /// and adds its view as a subview of the current view controller's view.
    /// - Note: The default implementation of this method REMOVES the previous `ViewControllable` from the view hierarchy.
    func transition(to newFlow: ViewControllable, completion: (() -> Void)?)
    
    
    /// Clears any `ViewControllable` from the view hierarchy.
    /// - Parameter completion: A closure to be executed after the cleanup is complete.
    /// 
    /// The default implementation of this method removes the current `ViewControllable` from the view hierarchy.
    func cleanUp(completion: (() -> Void)?)
    
}



/// The attachment point of `WorkEvaluatingRIB`.
final class WorkEvaluatingRouter: ViewableRouter<WorkEvaluatingInteractable, WorkEvaluatingViewControllable> {
    
    
    /// Constructs an instance of ``WorkEvaluatingRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    override init(interactor: WorkEvaluatingInteractable, viewController: WorkEvaluatingViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
}



/// Conformance extension to the ``WorkEvaluatingRouting`` protocol.
/// Contains everything accessible or invokable by ``WorkEvaluatingInteractor``.
extension WorkEvaluatingRouter: WorkEvaluatingRouting {
    
    
    func dismiss() {
        viewController.uiviewController.dismiss(animated: true)
    }
    
}
