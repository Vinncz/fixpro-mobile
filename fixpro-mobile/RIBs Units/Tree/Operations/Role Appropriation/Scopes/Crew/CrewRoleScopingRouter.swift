import Foundation
import RIBs
import UIKit



/// Contract adhered to by ``CrewRoleScopingInteractor``, listing the attributes and/or actions 
/// that ``CrewRoleScopingRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol CrewRoleScopingInteractable: Interactable, TicketNavigatorListener, WorkCalendarListener, NewTicketListener, InboxNavigatorListener, PreferencesListener {
    
    
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
    
    
    var ticketNavigatorBuilder: TicketNavigatorBuildable
    var ticketNavigatorRouter: TicketNavigatorRouting?
    
    var workCalendarBuilder: WorkCalendarBuildable
    var workCalendarRouter: WorkCalendarRouting?
    
    var newTicketBuilder: NewTicketBuildable
    var newTicketRouter: NewTicketRouting?
    
    var inboxNavigatorBuilder: InboxNavigatorBuildable
    var inboxNavigatorRouter: InboxNavigatorRouting?
    
    var preferencesBuilder: PreferencesBuildable
    var preferencesRouter: PreferencesRouting?
    
    
    /// Constructs an instance of ``CrewRoleScopingRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    init(interactor: CrewRoleScopingInteractable, viewController: CrewRoleScopingViewControllable, ticketNavigatorBuilder: TicketNavigatorBuilder, workCalendarBuilder: WorkCalendarBuildable, newTicketBuilder: NewTicketBuildable, inboxNavigatorBuilder: InboxNavigatorBuildable, preferencesBuilder: PreferencesBuildable) {
        self.ticketNavigatorBuilder = ticketNavigatorBuilder
        self.workCalendarBuilder = workCalendarBuilder
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
        
        let inboxNavigatorRouter = inboxNavigatorBuilder.build(withListener: interactor)
        self.inboxNavigatorRouter = inboxNavigatorRouter
        attachChild(inboxNavigatorRouter)
        
        let preferencesNav = UINavigationController()
        let preferencesRouter = preferencesBuilder.build(withListener: interactor)
        let preferencesRouterUITabBarItem = UITabBarItem(title: "Preferences", image: UIImage(systemName: "gear"), selectedImage: UIImage(systemName: "gear.fill"))
        preferencesRouter.viewControllable.uiviewController.tabBarItem = preferencesRouterUITabBarItem
        preferencesNav.viewControllers = [preferencesRouter.viewControllable.uiviewController]
        attachChild(preferencesRouter)
        self.preferencesRouter = preferencesRouter
        
        (viewControllable.uiviewController as? UITabBarController)?.viewControllers = [
            ticketNavigatorRouter.viewControllable.uiviewController, 
            workCalendarNav, 
            nonViewOwningButton, 
            inboxNavigatorRouter.viewControllable.uiviewController, 
            preferencesNav
        ]
        
        viewController.newTicketViewController = {
            newTicketRouter.viewControllable.uiviewController
        }
    }
    
}



/// Conformance extension to the ``CrewRoleScopingRouting`` protocol.
/// Contains everything accessible or invokable by ``CrewRoleScopingInteractor``.
extension CrewRoleScopingRouter: CrewRoleScopingRouting {
    
    
//    func detachChildren() {
//        if let ticketNavigatorRouter {
//            ticketNavigatorRouter.viewControllable.uiviewController.view.removeFromSuperview()
//            ticketNavigatorRouter.viewControllable.uiviewController.removeFromParent()
//            detachChild(ticketNavigatorRouter)
//            self.ticketNavigatorRouter = nil
//        }
//
//        if let workCalendarRouter {
//            workCalendarRouter.viewControllable.uiviewController.view.removeFromSuperview()
//            workCalendarRouter.viewControllable.uiviewController.removeFromParent()
//            detachChild(workCalendarRouter)
//            self.workCalendarRouter = nil
//        }
//
//        if let newTicketRouter {
//            newTicketRouter.viewControllable.uiviewController.view.removeFromSuperview()
//            newTicketRouter.viewControllable.uiviewController.removeFromParent()
//            detachChild(newTicketRouter)
//            self.newTicketRouter = nil
//        }
//
//        if let inboxNavigatorRouter {
//            inboxNavigatorRouter.viewControllable.uiviewController.view.removeFromSuperview()
//            inboxNavigatorRouter.viewControllable.uiviewController.removeFromParent()
//            detachChild(inboxNavigatorRouter)
//            self.inboxNavigatorRouter = nil
//        }
//
//        if let preferencesRouter {
//            preferencesRouter.viewControllable.uiviewController.view.removeFromSuperview()
//            preferencesRouter.viewControllable.uiviewController.removeFromParent()
//            detachChild(preferencesRouter)
//            self.preferencesRouter = nil
//        }
//
//        viewControllable.uiviewController.dismiss(animated: false)
//        viewControllable.uiviewController.view.subviews.forEach { $0.removeFromSuperview() }
//        viewControllable.uiviewController.children.forEach { $0.removeFromParent() }
//
//        if let tabBar = viewControllable.uiviewController as? UITabBarController {
//            tabBar.viewControllers = []
//            tabBar.selectedIndex = 0
//            tabBar.selectedViewController = nil
//        }
//    }
    
}
