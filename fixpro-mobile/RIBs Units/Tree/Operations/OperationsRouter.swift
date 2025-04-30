import Foundation
import RIBs
import VinUtility



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
    
    
    /// Removes the hosting controller from the view hierarchy and deallocates it.
    func nilHostingViewController()
    
}



/// The attachment point of `OperationsRIB`.
final class OperationsRouter: ViewableRouter<OperationsInteractable, OperationsViewControllable> {
    
    
    var roleAppropriationBuilder: RoleAppropriationBuildable
    var roleAppropriationRouter: RoleAppropriationRouting?
    
    
    /// Constructs an instance of ``OperationsRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    init(interactor: OperationsInteractable, viewController: OperationsViewControllable, roleAppropriationBuilder: RoleAppropriationBuildable) {
        self.roleAppropriationBuilder = roleAppropriationBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
}



/// Conformance extension to the ``OperationsRouting`` protocol.
/// Contains everything accessible or invokable by ``OperationsInteractor``.
extension OperationsRouter: OperationsRouting {
    
    
    func routeToRoleAppropriation(fromNotification notif: FPNotificationDigest? = nil) {
        Task { @MainActor in
            guard roleAppropriationRouter == nil else { return }
            
            VULogger.log("Routing to RoleAppropriation")
            
            let roleAppropriationRouter = roleAppropriationBuilder.build(withListener: interactor, triggerNotification: notif)
            self.roleAppropriationRouter = roleAppropriationRouter
            
            attachChild(roleAppropriationRouter)
            self.viewController.transition(to: roleAppropriationRouter.viewControllable, completion: nil)
        }
    }
    
    
    func cleanupViews() {
        Task { @MainActor in
            guard let roleAppropriationRouter else { return }
            
            VULogger.log("Detaching role appropriation")
            viewController.cleanUp(completion: nil)
            
            detachChild(roleAppropriationRouter)
            
            self.roleAppropriationRouter = nil
        }
    }
    
    
    func removeSwiftUI() {
        viewController.nilHostingViewController()
    }
    
}
