import RIBs
import UIKit



/// Contract adhered to by ``ManagementRoleScopingInteractor``, listing the attributes and/or actions 
/// that ``ManagementRoleScopingRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol ManagementRoleScopingInteractable: Interactable, TicketNavigatorListener, WorkCalendarListener, AreaManagementListener, InboxNavigatorListener, PreferencesListener {
    
    
    /// Reference to ``ManagementRoleScopingRouter``.
    var router: ManagementRoleScopingRouting? { get set }
    
    
    /// Reference to this RIB's parent's Interactor.
    var listener: ManagementRoleScopingListener? { get set }
    
}



/// Contract adhered to by ``ManagementRoleScopingViewController``, listing the attributes and/or actions
/// that ``ManagementRoleScopingRouter`` is allowed to access or invoke.
protocol ManagementRoleScopingViewControllable: ViewControllable {}



/// The attachment point of `ManagementRoleScopingRIB`.
final class ManagementRoleScopingRouter: ViewableRouter<ManagementRoleScopingInteractable, ManagementRoleScopingViewControllable> {
    
    
    var ticketNavigatorBuilder: TicketNavigatorBuildable
    var ticketNavigatorRouter: TicketNavigatorRouting?
    
    var workCalendarBuilder: WorkCalendarBuildable
    var workCalendarRouter: WorkCalendarRouting?
    
    var areaManagementBuilder: AreaManagementBuildable
    var areaManagementRouter: AreaManagementRouting?
    
    var inboxNavigatorBuilder: InboxNavigatorBuildable
    var inboxNavigatorRouter: InboxNavigatorRouting?
    
    var preferencesBuilder: PreferencesBuildable
    var preferencesRouter: PreferencesRouting?
    
    
    /// Constructs an instance of ``ManagementRoleScopingRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    init(interactor: ManagementRoleScopingInteractable, viewController: ManagementRoleScopingViewControllable, ticketNavigatorBuilder: TicketNavigatorBuildable, workCalendarBuilder: WorkCalendarBuildable, areaManagementBuilder: AreaManagementBuildable, inboxNavigatorBuilder: InboxNavigatorBuildable, preferencesBuilder: PreferencesBuildable) {
        self.ticketNavigatorBuilder = ticketNavigatorBuilder
        self.workCalendarBuilder = workCalendarBuilder
        self.areaManagementBuilder = areaManagementBuilder
        self.inboxNavigatorBuilder = inboxNavigatorBuilder
        self.preferencesBuilder = preferencesBuilder
        
        super.init(interactor: interactor, viewController: viewController)
        
        interactor.router = self
    }
    
    
    /// 
    override func didLoad() {
        super.didLoad()
        
        let ticketNavigatorRouter = ticketNavigatorBuilder.build(withListener: interactor)
        self.ticketNavigatorRouter = ticketNavigatorRouter
        attachChild(ticketNavigatorRouter)
        
        let workCalendarNav = UINavigationController()
        let workCalendarRouter = workCalendarBuilder.build(withListener: interactor)
        let workCalendarRouterUITabBarItem = UITabBarItem(title: "Calendar", image: UIImage(systemName: "calendar"), selectedImage: UIImage(systemName: "calendar.fill"))
        workCalendarRouter.viewControllable.uiviewController.tabBarItem = workCalendarRouterUITabBarItem
        workCalendarNav.viewControllers = [workCalendarRouter.viewControllable.uiviewController]
        self.workCalendarRouter = workCalendarRouter
        attachChild(workCalendarRouter)
        
        let areaManagementNav = UINavigationController()
        let areaManegementRouter = areaManagementBuilder.build(withListener: interactor)
        let areaManagementRouterUITabBarItem = UITabBarItem(title: "Areas", image: UIImage(systemName: "shield.lefthalf.filled"), selectedImage: UIImage(systemName: "shield.fill"))
        areaManegementRouter.viewControllable.uiviewController.tabBarItem = areaManagementRouterUITabBarItem
        areaManagementNav.viewControllers = [areaManegementRouter.viewControllable.uiviewController]
        self.areaManagementRouter = areaManegementRouter
        attachChild(areaManegementRouter)
        
        let inboxNavigatorRouter = inboxNavigatorBuilder.build(withListener: interactor)
        self.inboxNavigatorRouter = inboxNavigatorRouter
        attachChild(inboxNavigatorRouter)
        
        let preferencesNav = UINavigationController()
        let preferencesRouter = preferencesBuilder.build(withListener: interactor)
        let preferencesRouterUITabBarItem = UITabBarItem(title: "Preferences", image: UIImage(systemName: "gear"), selectedImage: UIImage(systemName: "gear.fill"))
        preferencesRouter.viewControllable.uiviewController.tabBarItem = preferencesRouterUITabBarItem
        preferencesNav.viewControllers = [preferencesRouter.viewControllable.uiviewController]
        self.preferencesRouter = preferencesRouter
        attachChild(preferencesRouter)
        
        (viewControllable.uiviewController as? UITabBarController)?.viewControllers = [
            ticketNavigatorRouter.viewControllable.uiviewController, 
            workCalendarNav, 
            areaManagementNav, 
            inboxNavigatorRouter.viewControllable.uiviewController, 
            preferencesNav
        ]
    }
    
}



/// Conformance extension to the ``ManagementRoleScopingRouting`` protocol.
/// Contains everything accessible or invokable by ``ManagementRoleScopingInteractor``.
extension ManagementRoleScopingRouter: ManagementRoleScopingRouting {}
