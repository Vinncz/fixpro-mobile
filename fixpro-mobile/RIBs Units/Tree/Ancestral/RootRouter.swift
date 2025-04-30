import Foundation
import VinUtility
import RIBs



/// Contract adhered to by ``RootInteractor``, listing the attributes and/or actions 
/// that ``RootRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol RootInteractable: Interactable, OnboardingListener, OperationsListener {
    
    
    /// Reference to ``RootRouter``.
    var router: RootRouting? { get set }
    
    
    /// Reference to this RIB's parent's Interactor.
    var listener: RootListener? { get set }
    
    
    /// 
    func deeplink(notification: FPNotificationDigest)
    
}



/// Contract adhered to by ``RootViewController``, listing the attributes and/or actions
/// that ``RootRouter`` is allowed to access or invoke.
protocol RootViewControllable: ViewControllable {
    
    
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



/// The attachment point of `RootRIB`.
final class RootRouter: LaunchRouter<RootInteractable, RootViewControllable> {
    
    
    var onboardingBuilder: OnboardingBuildable
    var onboardingRouter: OnboardingRouting?
    
    var operationsBuilder: OperationsBuildable
    var operationsRouter: OperationsRouting?
    
    
    /// Constructs an instance of ``RootRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    init(interactor: RootInteractable, viewController: RootViewControllable, onboardingBuilder: OnboardingBuildable, operationsBuilder: OperationsBuildable) {
        self.onboardingBuilder = onboardingBuilder
        self.operationsBuilder = operationsBuilder
        
        super.init(interactor: interactor, viewController: viewController)
        
        interactor.router = self
    }
    
}



/// Conformance extension to the ``RootRouting`` protocol.
/// Contains everything accessible or invokable by ``RootInteractor``
extension RootRouter: RootRouting {
    
    func operationalFlow(fromNotification notification: FPNotificationDigest? = nil) {
        Task { @MainActor in
            clearAllFlows()
            
            let operationsRouter = operationsBuilder.build(withListener: interactor, triggerNotification: notification)
            self.operationsRouter = operationsRouter
            
            attachChild(operationsRouter)
            viewController.transition(to: operationsRouter.viewControllable, completion: nil)
        }
    }
    
    
    func onboardingFlow() {
        Task { @MainActor in
            clearAllFlows()
            
            let onboardingRouter = onboardingBuilder.build(withListener: interactor)
            self.onboardingRouter = onboardingRouter
            
            attachChild(onboardingRouter)
            viewController.transition(to: onboardingRouter.viewControllable, completion: nil)
        }
    }
    
    
    func clearAllFlows() {
        if let onboardingRouter {
            viewController.cleanUp(completion: nil)
            detachChild(onboardingRouter)
            self.onboardingRouter = nil
        }
        
        if let operationsRouter {
            viewController.cleanUp(completion: nil)
            detachChild(operationsRouter)
            self.operationsRouter = nil
        }
    }
    
}
