import RIBs
import VinUtility
import UIKit



/// Contract adhered to by ``InboxNavigatorInteractor``, listing the attributes and/or actions 
/// that ``InboxNavigatorRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol InboxNavigatorInteractable: Interactable, InboxListener, TicketDetailListener, TicketLogListener {
    
    
    /// Reference to ``InboxNavigatorRouter``.
    var router: InboxNavigatorRouting? { get set }
    
    
    /// Reference to this RIB's parent's Interactor.
    var listener: InboxNavigatorListener? { get set }
    
}



/// Contract adhered to by ``InboxNavigatorViewController``, listing the attributes and/or actions
/// that ``InboxNavigatorRouter`` is allowed to access or invoke.
protocol InboxNavigatorViewControllable: ViewControllable {
    
    
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



/// The attachment point of `InboxNavigatorRIB`.
final class InboxNavigatorRouter: ViewableRouter<InboxNavigatorInteractable, InboxNavigatorViewControllable> {
    
    
    var inboxBuilder: InboxBuildable
    var inboxRouter: InboxRouting?
    
    var ticketDetailBuilder: TicketDetailBuildable
    var ticketDetailRouter: TicketDetailRouting?
    
    var ticketLogBuilder: TicketLogBuildable
    var ticketLogRouter: TicketLogRouting?
    
    
    /// Constructs an instance of ``InboxNavigatorRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    init(interactor: InboxNavigatorInteractable, viewController: InboxNavigatorViewControllable, inboxBuilder: InboxBuildable, ticketDetailBuilder: TicketDetailBuildable, ticketLogBuilder: TicketLogBuildable) {
        self.ticketDetailBuilder = ticketDetailBuilder
        self.inboxBuilder = inboxBuilder
        self.ticketLogBuilder = ticketLogBuilder
        
        super.init(interactor: interactor, viewController: viewController)
        
        interactor.router = self
    }
    
    
    /// Customization point that is invoked after self becomes active.
    override func didLoad() {
        loadInbox()
    }
    
}



extension InboxNavigatorRouter {
    
    
    func loadInbox() {
        let inboxRouter = inboxBuilder.build(withListener: interactor)
        self.inboxRouter = inboxRouter
        
        self.attachChild(inboxRouter)
        self.viewController.push(inboxRouter.viewControllable, animated: true)
    }
    
}



/// Conformance extension to the ``InboxNavigatorRouting`` protocol.
/// Contains everything accessible or invokable by ``InboxNavigatorInteractor``.
extension InboxNavigatorRouter: InboxNavigatorRouting {
    
    
    func deeplinkTo(ticket: FPTicketDetail) {
        // When already viewing a ticket detail; yet are asked to display a different one,
        // simply reject the request.
        if nil != ticketDetailRouter {
            viewController.popToRoot(animated: true)
            return
        }
        
        let ticketDetailRouter = ticketDetailBuilder.build(withListener: interactor, ticket: ticket, ticketId: nil)
        self.ticketDetailRouter = ticketDetailRouter
        
        self.attachChild(ticketDetailRouter)
        self.viewController.push(ticketDetailRouter.viewControllable, animated: true)
    }
    
    
    func deeplinkTo(ticketLog: FPTicketLog) {
        if nil != ticketLogRouter {
            viewController.popToRoot(animated: true)
            return
        }
        
        let ticketLogRouter = ticketLogBuilder.build(withListener: interactor, ticketLog: ticketLog)
        self.ticketLogRouter = ticketLogRouter
        
        attachChild(ticketLogRouter)
        viewController.push(ticketLogRouter.viewControllable, animated: true)
        
        // TODO: After ticket detail is loaded, push once more to ticketlog
    }
    
    
    func navigateToMailList() {
        viewController.popToRoot(animated: true)
        detachTicketLogRIB()
        detachTicketDetailRIB()
    }
    
    
    func navigateBackToTicketDetail() {
        detachTicketLogRIB()
    }
    
    
    /// Cleanses the view hierarchy of any `ViewControllable` instances this RIB may have added.
    func cleanupViews() {
        viewController.set([], animated: false)
        detachTicketLogRIB()
        detachInboxRIB()
    }
    
}



fileprivate extension InboxNavigatorRouter {
    
    
    func detachTicketLogRIB() {
        if let ticketLogRouter {
            self.detachChild(ticketLogRouter)
            self.ticketLogRouter = nil
        }
    }
    
    
    func detachTicketDetailRIB() {
        if let ticketDetailRouter {
            self.detachChild(ticketDetailRouter)
            self.ticketDetailRouter = nil
        }
    }
    
    
    func detachInboxRIB() {
        if let inboxRouter {
            self.detachChild(inboxRouter)
            self.inboxRouter = nil
        }
    }
    
}
