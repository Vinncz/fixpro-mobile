import Foundation
import RIBs



/// Contract adhered to by ``OperationsInteractor``, listing the attributes and/or actions 
/// that ``OperationsRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol OperationsInteractable: Interactable, RoleAppropriationListener {
    var router: OperationsRouting? { get set }
    var listener: OperationsListener? { get set }
}



/// Contract adhered to by ``OperationsViewController``, listing the attributes and/or actions
/// that ``OperationsRouter`` is allowed to access or invoke.
protocol OperationsViewControllable: ViewControllable {
    
    
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



/// The attachment point of `OperationsRIB`.
final class OperationsRouter: Router<OperationsInteractable> {
    
    
    /// Reference to the view this RIB manages.
    private let controlledView: OperationsViewControllable
    
    
    var roleAppropriationBuilder: RoleAppropriationBuildable
    var roleAppropriationRouter: RoleAppropriationRouting?
    
    
    /// Constructs an instance of ``OperationsRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    init(interactor: OperationsInteractable, viewController: OperationsViewControllable, roleAppropriationBuilder: RoleAppropriationBuildable) {
        self.roleAppropriationBuilder = roleAppropriationBuilder
        self.controlledView = viewController
        
        super.init(interactor: interactor)
        
        interactor.router = self
    }
    
    
    /// Customization point that is invoked before self is detached.
    /// Used to remove any views this RIB may have added to the view hierarchy.
    func cleanupViews() {}
    
}



/// Conformance extension to the ``OperationsRouting`` protocol.
/// Contains everything accessible or invokable by ``OperationsInteractor``.
extension OperationsRouter: OperationsRouting {
    
    
    func routeToRoleAppropriation() {
        guard roleAppropriationRouter == nil else { return }
        
        let roleAppropriationRouter = roleAppropriationBuilder.build(withListener: interactor)
        self.roleAppropriationRouter = roleAppropriationRouter
        
        attachChild(roleAppropriationRouter)
        DispatchQueue.main.sync {
            controlledView.transition(to: roleAppropriationRouter.viewControllable, completion: nil)
        }
    }
    
}
