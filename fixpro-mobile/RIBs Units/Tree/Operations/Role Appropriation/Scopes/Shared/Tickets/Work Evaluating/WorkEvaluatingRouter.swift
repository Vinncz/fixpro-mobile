import RIBs



/// Contract adhered to by ``WorkEvaluatingInteractor``, listing the attributes and/or actions 
/// that ``WorkEvaluatingRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol WorkEvaluatingInteractable: Interactable {
    
    
    /// Reference to ``WorkEvaluatingRouter``.
    var router: WorkEvaluatingRouting? { get set }
    
    
    /// Reference to this RIB's parent's Interactor.
    var listener: WorkEvaluatingListener? { get set }
    
}



/// Contract adhered to by ``WorkEvaluatingViewController``, listing the attributes and/or actions
/// that ``WorkEvaluatingRouter`` is allowed to access or invoke.
protocol WorkEvaluatingViewControllable: ViewControllable {
    
    
    /// Attaches the given `ViewControllable` into the view hierarchy, becoming the top-most view controller.
    /// - Parameter newFlow: The `ViewControllable` to be attached.
    /// - Parameter completion: A closure to be executed after the operation is complete.
    /// 
    /// > Note: You are responsible for removing the previous `ViewControllable` from the view hierarchy.
    func attach(newFlow: ViewControllable, completion: (() -> Void)?)
    
    
    /// Clears the  `ViewControllable` from the view hierarchy.
    /// - Parameter completion: A closure to be executed after the cleanup is complete.
    func clear(completion: (() -> Void)?)
    
    
    /// Removes the hosting controller from the view hierarchy and deallocates it.
    func nilHostingViewController()
    
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
    
    
    /// Customization point that is invoked after self becomes active.
    override func didLoad() {}
    
}



/// Conformance extension to the ``WorkEvaluatingRouting`` protocol.
/// Contains everything accessible or invokable by ``WorkEvaluatingInteractor``.
extension WorkEvaluatingRouter: WorkEvaluatingRouting {
    
    
    /// Removes the view hierarchy from any `ViewControllable` instances this RIB may have added.
    func clearViewControllers() {
        viewController.clear(completion: nil)
        // TODO: detach any child RIBs
        // TODO: nullify any references to child RIBs
    }
    
    
    /// Removes the hosting controller (swiftui embed) from the view hierarchy and deallocates it.
    func detachSwiftUI() {
        viewController.nilHostingViewController()
    }
    
    
    func dismiss() {
        Task { @MainActor in
            viewController.uiviewController.parent?.dismiss(animated: true)
            viewController.uiviewController.presentingViewController?.dismiss(animated: true)
        }
    }
    
}
