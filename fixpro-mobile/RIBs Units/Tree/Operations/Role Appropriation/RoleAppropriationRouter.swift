import Foundation
import RIBs



/// Contract adhered to by ``RoleAppropriationInteractor``, listing the attributes and/or actions 
/// that ``RoleAppropriationRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol RoleAppropriationInteractable: Interactable, MemberRoleScopingListener, CrewRoleScopingListener, ManagementRoleScopingListener {
    var router: RoleAppropriationRouting? { get set }
    var listener: RoleAppropriationListener? { get set }
}



/// Contract adhered to by ``RoleAppropriationViewController``, listing the attributes and/or actions
/// that ``RoleAppropriationRouter`` is allowed to access or invoke.
protocol RoleAppropriationViewControllable: ViewControllable {
    
    
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



/// The attachment point of `RoleAppropriationRIB`.
final class RoleAppropriationRouter: ViewableRouter<RoleAppropriationInteractable, RoleAppropriationViewControllable> {
    
    
    var activeRouting: Routing? = nil
    
    
    /// Constructs an instance of ``RoleAppropriationRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    override init(interactor: RoleAppropriationInteractable, viewController: RoleAppropriationViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
}



/// Conformance extension to the ``RoleAppropriationRouting`` protocol.
/// Contains everything accessible or invokable by ``RoleAppropriationInteractor``.
extension RoleAppropriationRouter: RoleAppropriationRouting {
    
    
    /// Transitions to role-scoped flow.
    func provisionMemberScope(component: RoleAppropriationComponent, triggerNotification: FPNotificationDigest?) {
        Task { @MainActor [weak self] in
            let sessionIdentityService = component.sessionIdentityService
            await component.authorizationContextProxy.back(with: .init(role: .member, capabilities: sessionIdentityService.capabilities, specialties: sessionIdentityService.specialties))
            
            guard let self else { return }
            let builder = MemberRoleScopingBuilder(dependency: component)
            let router = builder.build(withListener: interactor, triggerNotification: triggerNotification)
            self.activeRouting = router
            attachChild(router)
            
            viewController.transition(to: router.viewControllable, completion: nil)
        }
    }
    
    
    /// Transitions to role-scoped flow.
    func provisionCrewScope(component: RoleAppropriationComponent, triggerNotification: FPNotificationDigest?) {
        Task { @MainActor [weak self] in
            let sessionIdentityService = component.sessionIdentityService
            await component.authorizationContextProxy.back(with: .init(role: .crew, capabilities: sessionIdentityService.capabilities, specialties: sessionIdentityService.specialties))
            
            guard let self else { return }
            let builder = CrewRoleScopingBuilder(dependency: component)
            let router = builder.build(withListener: interactor, triggerNotification: triggerNotification)
            self.activeRouting = router
            attachChild(router)
            
            viewController.transition(to: router.viewControllable, completion: nil)
        }
    }
    
    
    /// Transitions to role-scoped flow.
    func provisionManagementScope(component: RoleAppropriationComponent, triggerNotification: FPNotificationDigest?) {
        Task { @MainActor [weak self] in
            let sessionIdentityService = component.sessionIdentityService
            await component.authorizationContextProxy.back(with: .init(role: .management, capabilities: sessionIdentityService.capabilities, specialties: sessionIdentityService.specialties))
            
            guard let self else { return }
            let builder = ManagementRoleScopingBuilder(dependency: component)
            let router = builder.build(withListener: interactor, triggerNotification: triggerNotification)
            self.activeRouting = router
            attachChild(router)
            
            viewController.transition(to: router.viewControllable, completion: nil)
        }
    }
    
    
    func cleanupViews() {
        viewController.cleanUp(completion: nil)
        guard let activeRouting else { return }
        detachChild(activeRouting)
        self.activeRouting = nil
    }
    
}
