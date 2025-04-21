import RIBs
import UIKit



/// Contract adhered to by ``ManagementRoleScopingInteractor``, listing the attributes and/or actions 
/// that ``ManagementRoleScopingRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol ManagementRoleScopingInteractable: Interactable, TicketListsListener, WorkCalendarListener, AreaManagementListener, InboxListener, PreferencesListener {
    
    
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
    
    
    var ticketListBuilder: TicketListsBuildable
    var ticketListRouter: TicketListsRouting?
    
    var workCalendarBuilder: WorkCalendarBuildable
    var workCalendarRouter: WorkCalendarRouting?
    
    var areaManagementBuilder: AreaManagementBuildable
    var areaManagementRouter: AreaManagementRouting?
    
    var inboxBuilder: InboxBuildable
    var inboxRouter: InboxRouting?
    
    var preferencesBuilder: PreferencesBuildable
    var preferencesRouter: PreferencesRouting?
    
    
    /// Constructs an instance of ``ManagementRoleScopingRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    init(interactor: ManagementRoleScopingInteractable, viewController: ManagementRoleScopingViewControllable, ticketListBuilder: TicketListsBuildable, workCalendarBuilder: WorkCalendarBuildable, areaManagementBuilder: AreaManagementBuildable, inboxBuilder: InboxBuildable, preferencesBuilder: PreferencesBuildable) {
        self.ticketListBuilder = ticketListBuilder
        self.workCalendarBuilder = workCalendarBuilder
        self.areaManagementBuilder = areaManagementBuilder
        self.inboxBuilder = inboxBuilder
        self.preferencesBuilder = preferencesBuilder
        
        super.init(interactor: interactor, viewController: viewController)
        
        interactor.router = self
    }
    
    
    /// 
    override func didLoad() {
        super.didLoad()
        
        let ticketNav = UINavigationController()
        let ticketListRouter = ticketListBuilder.build(withListener: interactor)
        let ticketListRouterUITabBarItem = UITabBarItem(title: "Tickets", image: UIImage(systemName: "ticket"), selectedImage: UIImage(systemName: "ticket.fill"))
        ticketListRouter.viewControllable.uiviewController.tabBarItem = ticketListRouterUITabBarItem
        ticketNav.viewControllers = [ticketListRouter.viewControllable.uiviewController]
        self.ticketListRouter = ticketListRouter
        attachChild(ticketListRouter)
        
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
        
        let inboxNav = UINavigationController()
        let inboxRouter = inboxBuilder.build(withListener: interactor)
        let inboxRouterUITabBarItem = UITabBarItem(title: "Inbox", image: UIImage(systemName: "bell"), selectedImage: UIImage(systemName: "bell.fill"))
        inboxRouter.viewControllable.uiviewController.tabBarItem = inboxRouterUITabBarItem
        inboxNav.viewControllers = [inboxRouter.viewControllable.uiviewController]
        self.inboxRouter = inboxRouter
        attachChild(inboxRouter)
        
        let preferencesNav = UINavigationController()
        let preferencesRouter = preferencesBuilder.build(withListener: interactor)
        let preferencesRouterUITabBarItem = UITabBarItem(title: "Preferences", image: UIImage(systemName: "gear"), selectedImage: UIImage(systemName: "gear.fill"))
        preferencesRouter.viewControllable.uiviewController.tabBarItem = preferencesRouterUITabBarItem
        preferencesNav.viewControllers = [preferencesRouter.viewControllable.uiviewController]
        self.preferencesRouter = preferencesRouter
        attachChild(preferencesRouter)
        
        (viewControllable.uiviewController as? UITabBarController)?.viewControllers = [
            ticketNav, workCalendarNav, areaManagementNav, inboxNav, preferencesNav
        ]
    }
    
}



/// Conformance extension to the ``ManagementRoleScopingRouting`` protocol.
/// Contains everything accessible or invokable by ``ManagementRoleScopingInteractor``.
extension ManagementRoleScopingRouter: ManagementRoleScopingRouting {}
