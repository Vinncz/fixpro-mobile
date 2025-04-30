import RIBs
import VinUtility
import UIKit



/// Contract adhered to by ``TicketNavigatorInteractor``, listing the attributes and/or actions 
/// that ``TicketNavigatorRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol TicketNavigatorInteractable: Interactable, TicketListsListener, TicketDetailListener, TicketLogListener {
    
    
    /// Reference to ``TicketNavigatorRouter``.
    var router: TicketNavigatorRouting? { get set }
    
    
    /// Reference to this RIB's parent's Interactor.
    var listener: TicketNavigatorListener? { get set }
    
}



/// Contract adhered to by ``TicketNavigatorViewController``, listing the attributes and/or actions
/// that ``TicketNavigatorRouter`` is allowed to access or invoke.
protocol TicketNavigatorViewControllable: ViewControllable {
    
    
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



/// The attachment point of `TicketNavigatorRIB`.
final class TicketNavigatorRouter: ViewableRouter<TicketNavigatorInteractable, TicketNavigatorViewControllable> {
    
    
    var ticketListBuilder: TicketListsBuildable
    var ticketListRouter: TicketListsRouting?
    
    var ticketDetailBuilder: TicketDetailBuildable
    var ticketDetailRouter: TicketDetailRouting?
    
    var ticketLogBuilder: TicketLogBuildable
    var ticketLogRouter: TicketLogRouting?
    
    
    /// Constructs an instance of ``TicketNavigatorRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    init(interactor: TicketNavigatorInteractable, viewController: TicketNavigatorViewControllable, ticketListBuilder: TicketListsBuildable, ticketDetailsBuilder: TicketDetailBuildable, ticketLogBuilder: TicketLogBuildable) {
        self.ticketListBuilder = ticketListBuilder
        self.ticketDetailBuilder = ticketDetailsBuilder
        self.ticketLogBuilder = ticketLogBuilder
        
        super.init(interactor: interactor, viewController: viewController)
        
        interactor.router = self
    }
    
    
    /// Customization point that is invoked after self becomes active.
    override func didLoad() {
        loadTicketList()
    }
    
}



extension TicketNavigatorRouter {
    
    
    func loadTicketList() {
        let ticketListRouter = ticketListBuilder.build(withListener: interactor)
        self.ticketListRouter = ticketListRouter
        
        self.attachChild(ticketListRouter)
        self.viewController.push(ticketListRouter.viewControllable, animated: true)
    }
    
}



/// Conformance extension to the ``TicketNavigatorRouting`` protocol.
/// Contains everything accessible or invokable by ``TicketNavigatorInteractor``.
extension TicketNavigatorRouter: TicketNavigatorRouting {
    
    
    func flowTo(ticketId: String) {
        // When already viewing a ticket detail; yet are asked to display a different one,
        // simply reject the request.
        if nil != ticketDetailRouter {
            viewController.popToRoot(animated: true)
            return
        }
        
        let ticketDetailRouter = ticketDetailBuilder.build(withListener: interactor, ticket: nil, ticketId: ticketId)
        self.ticketDetailRouter = ticketDetailRouter
        
        self.attachChild(ticketDetailRouter)
        self.viewController.push(ticketDetailRouter.viewControllable, animated: true)
    }
    
    
    func flowTo(ticket: FPTicketDetail) {
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
    
    
    func flowTo(ticketLog: FPTicketLog) {
        // When already viewing a ticket log; yet are asked to display a different one,
        // simply reject the request.
        if nil != ticketLogRouter {
            viewController.pop(animated: true)
            return
        }
        
        let ticketLogRouter = ticketLogBuilder.build(withListener: interactor, ticketLog: ticketLog)
        self.ticketLogRouter = ticketLogRouter
        
        self.attachChild(ticketLogRouter)
        self.viewController.push(ticketLogRouter.viewControllable, animated: true)
        
        // TODO: After ticket detail is loaded, push once more to ticketlog
    }
    
    
    func navigateToTicketList() {
        viewController.popToRoot(animated: true)
        detachTicketLogRIB()
        detachTicketDetailRIB()
    }
    
    
    func backToTicketDetail() {
        detachTicketLogRIB()
    }
    
    
    /// Cleanses the view hierarchy of any `ViewControllable` instances this RIB may have added.
    func cleanupViews() {
        viewController.set([], animated: false)
        detachTicketLogRIB()
        detachTicketListRIB()
    }
    
}



fileprivate extension TicketNavigatorRouter {
    
    
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
    
    
    func detachTicketListRIB() {
        if let ticketListRouter {
            self.detachChild(ticketListRouter)
            self.ticketListRouter = nil
        }
    }
    
}
