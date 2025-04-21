import RIBs
import UIKit



/// Contract adhered to by ``MemberRoleScopingInteractor``, listing the attributes and/or actions 
/// that ``MemberRoleScopingRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol MemberRoleScopingInteractable: Interactable, TicketListsListener, NewTicketListener, InboxListener, PreferencesListener {
    
    
    /// Reference to ``MemberRoleScopingRouter``.
    var router: MemberRoleScopingRouting? { get set }
    
    
    /// Reference to this RIB's parent's Interactor.
    var listener: MemberRoleScopingListener? { get set }
    
}



/// Contract adhered to by ``MemberRoleScopingViewController``, listing the attributes and/or actions
/// that ``MemberRoleScopingRouter`` is allowed to access or invoke.
protocol MemberRoleScopingViewControllable: ViewControllable {
    var newTicketViewController: (() -> UIViewController)? { get set }
}



/// The attachment point of `MemberRoleScopingRIB`.
final class MemberRoleScopingRouter: ViewableRouter<MemberRoleScopingInteractable, MemberRoleScopingViewControllable> {
    
    
    var ticketListBuilder: TicketListsBuildable
    var ticketListRouter: TicketListsRouting?
    
    var newTicketBuilder: NewTicketBuildable
    var newTicketRouter: NewTicketRouting?
    
    var inboxBuilder: InboxBuildable
    var inboxRouter: InboxRouting?
    
    var preferencesBuilder: PreferencesBuildable
    var preferencesRouter: PreferencesRouting?
    
    
    /// Constructs an instance of ``MemberRoleScopingRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    init(interactor: MemberRoleScopingInteractable, viewController: MemberRoleScopingViewControllable, ticketListBuilder: TicketListsBuildable, newTicketBuilder: NewTicketBuildable, inboxBuilder: InboxBuildable, preferencesBuilder: PreferencesBuildable) {
        self.ticketListBuilder = ticketListBuilder
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
        self.ticketListRouter = ticketListRouter
        attachChild(ticketListRouter)
        
        let nonViewOwningButton = UIViewController()
        nonViewOwningButton.tabBarItem = UITabBarItem(title: "New", image: UIImage(systemName: "plus.circle.fill"), tag: .MODALLY_PRESENTED_VIEW_CONTROLLER)
        let newTicketRouter = newTicketBuilder.build(withListener: interactor)
        self.newTicketRouter = newTicketRouter
        attachChild(newTicketRouter)
        
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
            ticketNav, nonViewOwningButton, inboxNav, preferencesNav
        ]
        
        viewController.newTicketViewController = {
            newTicketRouter.viewControllable.uiviewController
        }
    }
    
}



/// Conformance extension to the ``MemberRoleScopingRouting`` protocol.
/// Contains everything accessible or invokable by ``MemberRoleScopingInteractor``.
extension MemberRoleScopingRouter: MemberRoleScopingRouting {}
