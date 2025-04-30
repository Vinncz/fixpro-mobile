import RIBs
import UIKit



/// Contract adhered to by ``MemberRoleScopingInteractor``, listing the attributes and/or actions 
/// that ``MemberRoleScopingRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol MemberRoleScopingInteractable: Interactable, TicketNavigatorListener, NewTicketListener, InboxNavigatorListener, PreferencesListener {
    
    
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
    
    
    var ticketNavigatorBuilder: TicketNavigatorBuildable
    var ticketNavigatorRouter: TicketNavigatorRouting?
    
    var newTicketBuilder: NewTicketBuildable
    var newTicketRouter: NewTicketRouting?
    
    var inboxNavigatorBuilder: InboxNavigatorBuildable
    var inboxNavigatorRouter: InboxNavigatorRouting?
    
    var preferencesBuilder: PreferencesBuildable
    var preferencesRouter: PreferencesRouting?
    
    
    /// Constructs an instance of ``MemberRoleScopingRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    init(interactor: MemberRoleScopingInteractable, viewController: MemberRoleScopingViewControllable, ticketNavigatorBuilder: TicketNavigatorBuildable, newTicketBuilder: NewTicketBuildable, inboxNavigatorBuilder: InboxNavigatorBuildable, preferencesBuilder: PreferencesBuildable) {
        self.ticketNavigatorBuilder = ticketNavigatorBuilder
        self.newTicketBuilder = newTicketBuilder
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
        
        let nonViewOwningButton = UIViewController()
        nonViewOwningButton.tabBarItem = UITabBarItem(title: "New", image: UIImage(systemName: "plus.circle.fill"), tag: .MODALLY_PRESENTED_VIEW_CONTROLLER)
        let newTicketRouter = newTicketBuilder.build(withListener: interactor)
        self.newTicketRouter = newTicketRouter
        attachChild(newTicketRouter)
        
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
            nonViewOwningButton, 
            inboxNavigatorRouter.viewControllable.uiviewController, 
            preferencesNav
        ]
        
        viewController.newTicketViewController = {
            newTicketRouter.viewControllable.uiviewController
        }
    }
    
}



/// Conformance extension to the ``MemberRoleScopingRouting`` protocol.
/// Contains everything accessible or invokable by ``MemberRoleScopingInteractor``.
extension MemberRoleScopingRouter: MemberRoleScopingRouting {}
