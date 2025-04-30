import RIBs
import VinUtility



/// Contract adhered to by ``OnboardingInteractor``, listing the attributes and/or actions 
/// that ``OnboardingRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol OnboardingInteractable: Interactable, AreaJoinningListener {
    var router: OnboardingRouting? { get set }
    var listener: OnboardingListener? { get set }
}



/// Contract adhered to by ``OnboardingViewController``, listing the attributes and/or actions
/// that ``OnboardingRouter`` is allowed to access or invoke.
protocol OnboardingViewControllable: ViewControllable {
    
    
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
    
    
    func present(_ flow: ViewControllable)
    func dismiss(withoutDetachingView: Bool)
    
}



/// The attachment point of `OnboardingRIB`.
final class OnboardingRouter: ViewableRouter<OnboardingInteractable, OnboardingViewControllable> {
    
    
    var areaJoinningBuilder: AreaJoinningBuildable
    var areaJoinningRouter: AreaJoinningRouting?
    
    
    /// Constructs an instance of ``OnboardingRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    init(interactor: OnboardingInteractable, viewController: OnboardingViewControllable, areaJoinningBuilder: AreaJoinningBuildable) {
        self.areaJoinningBuilder = areaJoinningBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
}



/// Conformance extension to the ``OnboardingRouting`` protocol.
/// Contains everything accessible or invokable by ``OnboardingInteractor``
extension OnboardingRouter: OnboardingRouting {
    
    func pairingFlow() {
        VULogger.log("Attached AreaJoinningRIB")
        
        let areaJoinningRouter = areaJoinningBuilder.build(withListener: interactor)
        self.areaJoinningRouter = areaJoinningRouter
        
        self.attachChild(areaJoinningRouter)
        self.viewController.present(areaJoinningRouter.viewControllable)
    }
    
    func exitFlow() {
        guard let areaJoinningRouter else { return }
        
        VULogger.log("Detached AreaJoinningRIB")
        
        self.viewController.dismiss(withoutDetachingView: true)
        self.detachChild(areaJoinningRouter)
        self.areaJoinningRouter = nil
    }
    
}
