import RIBs
import UIKit



/// Contract adhered to by ``AreaManagementNavigatorInteractor``, listing the attributes and/or actions 
/// that ``AreaManagementNavigatorRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol AreaManagementNavigatorInteractable: Interactable, AreaManagementListener, AreaManagmentIssueTypesWithSLARegistrarListener, AreaManagementApplicationReviewAndManagementListener, AreaManagementStatisticsListener {
    
    
    /// Reference to ``AreaManagementNavigatorRouter``.
    var router: AreaManagementNavigatorRouting? { get set }
    
    
    /// Reference to this RIB's parent's Interactor.
    var listener: AreaManagementNavigatorListener? { get set }
    
}



/// Contract adhered to by ``AreaManagementNavigatorViewController``, listing the attributes and/or actions
/// that ``AreaManagementNavigatorRouter`` is allowed to access or invoke.
protocol AreaManagementNavigatorViewControllable: ViewControllable {
    
    
    /// Pushes the given `ViewControllable` onto the navigation stack.
    /// - Parameter viewControllable: The `ViewControllable` to be pushed.
    /// - Parameter animated: A Boolean value that indicates whether the transition should be animated.
    func push(_ viewControllable: ViewControllable, animated: Bool)
    
    
    /// Pops the top view controller off the navigation stack.
    /// - Parameter animated: A Boolean value that indicates whether the transition should be animated.
    /// - Returns: An optional view controller that was popped.
    @discardableResult func pop(animated: Bool) -> UIViewController?
    
    
    /// Pops all view controllers on the navigation stack until the root view controller is at the top.
    /// - Parameter animated: A Boolean value that indicates whether the transition should be animated.
    /// - Note: This method does not remove the root view controller from the navigation stack.
    /// - Returns: An optional array of view controllers that were popped.
    @discardableResult func popToRoot(animated: Bool) -> [UIViewController]?
    
    
    /// Sets the view controllers of the navigation stack.
    /// - Parameter viewControllables: An array of `ViewControllable` to be set as the new view controllers.
    /// - Parameter animated: A Boolean value that indicates whether the transition should be animated.
    func set(_ viewControllables: [ViewControllable], animated: Bool)
    
}



/// The attachment point of `AreaManagementNavigatorRIB`.
final class AreaManagementNavigatorRouter: ViewableRouter<AreaManagementNavigatorInteractable, AreaManagementNavigatorViewControllable> {
    
    
    var areaManagementBuilder: AreaManagementBuildable
    var areaManagementRouter: AreaManagementRouting?
    
    var areaManagmentIssueTypesWithSLARegistrarBuilder: AreaManagmentIssueTypesWithSLARegistrarBuildable
    var areaManagmentIssueTypesWithSLARegistrarRouter: AreaManagmentIssueTypesWithSLARegistrarRouting?
    
    var areaManagementApplicationReviewAndManagementBuilder: AreaManagementApplicationReviewAndManagementBuildable
    var areaManagementApplicationReviewAndManagementRouter: AreaManagementApplicationReviewAndManagementRouting?
    
    var areaManagementStatisticsBuilder: AreaManagementStatisticsBuildable
    var areaManagementStatisticsRouter: AreaManagementStatisticsRouting?
    
    
    /// Constructs an instance of ``AreaManagementNavigatorRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    init(interactor: AreaManagementNavigatorInteractable, viewController: AreaManagementNavigatorViewControllable, areaManagementBuilder: AreaManagementBuildable, areaManagmentIssueTypesWithSLARegistrarBuilder: AreaManagmentIssueTypesWithSLARegistrarBuildable, areaManagementApplicationReviewAndManagementBuilder: AreaManagementApplicationReviewAndManagementBuildable, areaManagementStatisticsBuilder: AreaManagementStatisticsBuildable) {
        self.areaManagementBuilder = areaManagementBuilder
        self.areaManagmentIssueTypesWithSLARegistrarBuilder = areaManagmentIssueTypesWithSLARegistrarBuilder
        self.areaManagementApplicationReviewAndManagementBuilder = areaManagementApplicationReviewAndManagementBuilder
        self.areaManagementStatisticsBuilder = areaManagementStatisticsBuilder
        
        super.init(interactor: interactor, viewController: viewController)
        
        interactor.router = self
    }
    
    
    /// Customization point that is invoked after self becomes active.
    override func didLoad() {
        loadManagementView()
    }
    
}



extension AreaManagementNavigatorRouter {
    
    
    func loadManagementView() {
        let router = areaManagementBuilder.build(withListener: interactor)
        self.areaManagementRouter = router
        
        self.attachChild(router)
        self.viewController.push(router.viewControllable, animated: false)
    }
    
}



/// Conformance extension to the ``AreaManagementNavigatorRouting`` protocol.
/// Contains everything accessible or invokable by ``AreaManagementNavigatorInteractor``.
extension AreaManagementNavigatorRouter: AreaManagementNavigatorRouting {
    
    
    func navigateToApplicationReviewAndManagement() {
        let router = areaManagementApplicationReviewAndManagementBuilder.build(withListener: interactor)
        self.areaManagementApplicationReviewAndManagementRouter = router
        
        self.attachChild(router)
        self.viewController.push(router.viewControllable, animated: true)
    }
    
    
    func navigateToIssueTypesWithSLARegistrar() {
        let router = areaManagmentIssueTypesWithSLARegistrarBuilder.build(withListener: interactor)
        self.areaManagmentIssueTypesWithSLARegistrarRouter = router
        
        self.attachChild(router)
        self.viewController.push(router.viewControllable, animated: true)
    }
    
    
    func navigateToStatistics() {
        let router = areaManagementStatisticsBuilder.build(withListener: interactor)
        self.areaManagementStatisticsRouter = router
        
        self.attachChild(router)
        self.viewController.push(router.viewControllable, animated: true)
    }
    
    
    func toRoot() {
        viewController.popToRoot(animated: true)
        detachARAM()
        detachITWSLAR()
        detachStatistics()
    }
    
    
    /// Cleanses the view hierarchy of any `ViewControllable` instances this RIB may have added.
    func cleanupViews() {
        viewController.set([], animated: false)
        detachARAM()
        detachITWSLAR()
        detachStatistics()
    }
    
}



extension AreaManagementNavigatorRouter {
    
    
    func detachARAM() {
        if let areaManagementApplicationReviewAndManagementRouter {
            detachChild(areaManagementApplicationReviewAndManagementRouter)
            self.areaManagementApplicationReviewAndManagementRouter = nil
        }
    }
    
    
    func detachITWSLAR() {
        if let areaManagmentIssueTypesWithSLARegistrarRouter {
            detachChild(areaManagmentIssueTypesWithSLARegistrarRouter)
            self.areaManagmentIssueTypesWithSLARegistrarRouter = nil
        }
    }
    
    
    func detachStatistics() {
        if let areaManagementStatisticsRouter {
            detachChild(areaManagementStatisticsRouter)
            self.areaManagementStatisticsRouter = nil
        }
    }
    
}
