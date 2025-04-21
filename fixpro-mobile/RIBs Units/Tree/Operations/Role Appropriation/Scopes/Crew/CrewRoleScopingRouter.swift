import Foundation
import RIBs
import UIKit



/// Contract adhered to by ``CrewRoleScopingInteractor``, listing the attributes and/or actions 
/// that ``CrewRoleScopingRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol CrewRoleScopingInteractable: Interactable, TicketListsListener, WorkCalendarListener, NewTicketListener, InboxListener, PreferencesListener {
    
    
    /// Reference to ``CrewRoleScopingRouter``.
    var router: CrewRoleScopingRouting? { get set }
    
    
    /// Reference to this RIB's parent's Interactor.
    var listener: CrewRoleScopingListener? { get set }
    
}



/// Contract adhered to by ``CrewRoleScopingViewController``, listing the attributes and/or actions
/// that ``CrewRoleScopingRouter`` is allowed to access or invoke.
protocol CrewRoleScopingViewControllable: ViewControllable {
    var newTicketViewController: (() -> UIViewController)? { get set }
}



/// The attachment point of `CrewRoleScopingRIB`.
final class CrewRoleScopingRouter: ViewableRouter<CrewRoleScopingInteractable, CrewRoleScopingViewControllable> {
    
    
    var ticketListBuilder: TicketListsBuildable
    var ticketListRouter: TicketListsRouting?
    
    var workCalendarBuilder: WorkCalendarBuildable
    var workCalendarRouter: WorkCalendarRouting?
    
    var newTicketBuilder: NewTicketBuildable
    var newTicketRouter: NewTicketRouting?
    
    var inboxBuilder: InboxBuildable
    var inboxRouter: InboxRouting?
    
    var preferencesBuilder: PreferencesBuildable
    var preferencesRouter: PreferencesRouting?
    
    
    /// Constructs an instance of ``CrewRoleScopingRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    init(interactor: CrewRoleScopingInteractable, viewController: CrewRoleScopingViewControllable, ticketListBuilder: TicketListsBuildable, workCalendarBuilder: WorkCalendarBuildable, newTicketBuilder: NewTicketBuildable, inboxBuilder: InboxBuildable, preferencesBuilder: PreferencesBuildable) {
        self.ticketListBuilder = ticketListBuilder
        self.workCalendarBuilder = workCalendarBuilder
        self.newTicketBuilder = newTicketBuilder
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
        attachChild(ticketListRouter)
        self.ticketListRouter = ticketListRouter
        
        let workCalendarNav = UINavigationController()
        let workCalendarRouter = workCalendarBuilder.build(withListener: interactor)
        let workCalendarRouterUITabBarItem = UITabBarItem(title: "Calendar", image: UIImage(systemName: "calendar"), selectedImage: UIImage(systemName: "calendar.fill"))
        workCalendarRouter.viewControllable.uiviewController.tabBarItem = workCalendarRouterUITabBarItem
        workCalendarNav.viewControllers = [workCalendarRouter.viewControllable.uiviewController]
        attachChild(workCalendarRouter)
        self.workCalendarRouter = workCalendarRouter
        
        let nonViewOwningButton = UIViewController()
        nonViewOwningButton.tabBarItem = UITabBarItem(title: "New", image: UIImage(systemName: "plus.circle.fill"), tag: .MODALLY_PRESENTED_VIEW_CONTROLLER)
        let newTicketRouter = newTicketBuilder.build(withListener: interactor)
        attachChild(newTicketRouter)
        self.newTicketRouter = newTicketRouter
        
        let inboxNav = UINavigationController()
        let inboxRouter = inboxBuilder.build(withListener: interactor)
        let inboxRouterUITabBarItem = UITabBarItem(title: "Inbox", image: UIImage(systemName: "bell"), selectedImage: UIImage(systemName: "bell.fill"))
        inboxRouter.viewControllable.uiviewController.tabBarItem = inboxRouterUITabBarItem
        inboxNav.viewControllers = [inboxRouter.viewControllable.uiviewController]
        attachChild(inboxRouter)
        self.inboxRouter = inboxRouter
        
        let preferencesNav = UINavigationController()
        let preferencesRouter = preferencesBuilder.build(withListener: interactor)
        let preferencesRouterUITabBarItem = UITabBarItem(title: "Preferences", image: UIImage(systemName: "gear"), selectedImage: UIImage(systemName: "gear.fill"))
        preferencesRouter.viewControllable.uiviewController.tabBarItem = preferencesRouterUITabBarItem
        preferencesNav.viewControllers = [preferencesRouter.viewControllable.uiviewController]
        attachChild(preferencesRouter)
        self.preferencesRouter = preferencesRouter
        
        (viewControllable.uiviewController as? UITabBarController)?.viewControllers = [
            ticketNav, workCalendarNav, nonViewOwningButton, inboxNav, preferencesNav
        ]
        
        viewController.newTicketViewController = {
            newTicketRouter.viewControllable.uiviewController
        }
    }
    
}



/// Conformance extension to the ``CrewRoleScopingRouting`` protocol.
/// Contains everything accessible or invokable by ``CrewRoleScopingInteractor``.
extension CrewRoleScopingRouter: CrewRoleScopingRouting {}
