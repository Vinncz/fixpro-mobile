import Foundation
import RIBs



/// Contract adhered to by ``TicketDetailInteractor``, listing the attributes and/or actions 
/// that ``TicketDetailRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol TicketDetailInteractable: Interactable, UpdateContributingListener, CrewDelegatingListener, CrewInvitingListener, WorkEvaluatingListener {
    var router: TicketDetailRouting? { get set }
    var listener: TicketDetailListener? { get set }
}



/// Contract adhered to by ``TicketDetailViewController``, listing the attributes and/or actions
/// that ``TicketDetailRouter`` is allowed to access or invoke.
protocol TicketDetailViewControllable: ViewControllable {
    
    
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
    
    
    func present(newFlow: ViewControllable, completion: (() -> Void)?)
    
}



/// The attachment point of `TicketDetailRIB`.
final class TicketDetailRouter: ViewableRouter<TicketDetailInteractable, TicketDetailViewControllable> {
    
    
    var updateContributingBuilder: UpdateContributingBuildable
    var updateContributingRouter: UpdateContributingRouting?
    var crewDelegatingBuilder: CrewDelegatingBuildable
    var crewDelegatingRouter: CrewDelegatingRouting?
    var crewInvitingBuilder: CrewInvitingBuildable
    var crewInvitingRouter: CrewInvitingRouting?
    var workEvaluatingBuilder: WorkEvaluatingBuildable
    var workEvaluatingRouter: WorkEvaluatingRouting?
    
    
    /// Constructs an instance of ``TicketDetailRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    init(interactor: TicketDetailInteractable, viewController: TicketDetailViewControllable, updateContributingBuilder: UpdateContributingBuildable, crewDelegatingBuilder: CrewDelegatingBuildable, crewInvitingBuilder: CrewInvitingBuildable, workEvaluatingBuilder: WorkEvaluatingBuildable) {
        self.updateContributingBuilder = updateContributingBuilder
        self.crewDelegatingBuilder = crewDelegatingBuilder
        self.crewInvitingBuilder = crewInvitingBuilder
        self.workEvaluatingBuilder = workEvaluatingBuilder
        
        super.init(interactor: interactor, viewController: viewController)
        
        interactor.router = self
    }
    
}



/// Conformance extension to the ``TicketDetailRouting`` protocol.
/// Contains everything accessible or invokable by ``TicketDetailInteractor``.
extension TicketDetailRouter: TicketDetailRouting {
    
    
    func attachFlowAddWorkReport(ticketId: String) {
        let router = updateContributingBuilder.build(withListener: interactor, ticketId: ticketId)
        self.updateContributingRouter = router
        
        self.attachChild(router)
        self.viewController.present(newFlow: router.viewControllable, completion: nil)
    }
    
    func detachFlowAddWorkReport() {
        if let updateContributingRouter {
            self.viewController.cleanUp(completion: nil)
            self.detachChild(updateContributingRouter)
            self.updateContributingRouter = nil
        }
    }
    
    
    func attachFlowDelegateTicket(ticket: FPTicketDetail) {
        let router = crewDelegatingBuilder.build(withListener: interactor, ticket: ticket)
        self.crewDelegatingRouter = router
        
        self.attachChild(router)
        self.viewController.present(newFlow: router.viewControllable, completion: nil)
    }
    
    func detachFlowDelegateTicket() {
        Task { @MainActor in
            if let crewDelegatingRouter {
                self.viewController.cleanUp(completion: nil)
                self.detachChild(crewDelegatingRouter)
                self.crewDelegatingRouter = nil
            }
        }
    }
    
    
    func attachFlowInviteTicket(ticket: FPTicketDetail) {
        let router = crewInvitingBuilder.build(withListener: interactor, ticket: ticket)
        self.crewInvitingRouter = router
        
        self.attachChild(router)
        self.viewController.present(newFlow: router.viewControllable, completion: nil)
    }
    
    func detachFlowInviteTicket() {
        Task { @MainActor in
            if let crewInvitingRouter {
                self.viewController.cleanUp(completion: nil)
                self.detachChild(crewInvitingRouter)
                self.crewInvitingRouter = nil
            }
        }
    }
    
    
    func attachFlowWorkEvaluating(ticket: FPTicketDetail) {
        let router = workEvaluatingBuilder.build(withListener: interactor, ticket: ticket)
        self.workEvaluatingRouter = router
        
        self.attachChild(router)
        self.viewController.present(newFlow: router.viewControllable, completion: nil)
    }
    
    func detachWorkEvaluating() {
        if let workEvaluatingRouter {
            self.viewController.cleanUp(completion: nil)
            self.detachChild(workEvaluatingRouter)
            self.workEvaluatingRouter = nil
        }
    } 
    
}
