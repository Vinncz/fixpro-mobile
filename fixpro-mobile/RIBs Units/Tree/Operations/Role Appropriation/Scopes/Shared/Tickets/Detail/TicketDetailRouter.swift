import Foundation
import RIBs



/// Contract adhered to by ``TicketDetailInteractor``, listing the attributes and/or actions 
/// that ``TicketDetailRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol TicketDetailInteractable: Interactable, CrewNewWorkLogListener, CrewDelegatingListener, WorkEvaluatingListener, TicketReportListener {
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
    
    
    var crewNewWorkLogBuilder: CrewNewWorkLogBuildable
    var crewNewWorkLogRouter: CrewNewWorkLogRouting?
    var crewDelegatingBuilder: CrewDelegatingBuildable
    var crewDelegatingRouter: CrewDelegatingRouting?
    var workEvaluatingBuilder: WorkEvaluatingBuildable
    var workEvaluatingRouter: WorkEvaluatingRouting?
    var ticketReportBuilder: TicketReportBuildable
    var ticketReportRouter: TicketReportRouting?
    
    
    /// Constructs an instance of ``TicketDetailRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    init(interactor: TicketDetailInteractable, viewController: TicketDetailViewControllable, crewNewWorkLogBuilder: CrewNewWorkLogBuildable, crewDelegatingBuilder: CrewDelegatingBuildable, workEvaluatingBuilder: WorkEvaluatingBuildable, ticketReportBuilder: TicketReportBuildable) {
        self.crewNewWorkLogBuilder = crewNewWorkLogBuilder
        self.crewDelegatingBuilder = crewDelegatingBuilder
        self.workEvaluatingBuilder = workEvaluatingBuilder
        self.ticketReportBuilder = ticketReportBuilder
        
        super.init(interactor: interactor, viewController: viewController)
        
        interactor.router = self
    }
    
}



/// Conformance extension to the ``TicketDetailRouting`` protocol.
/// Contains everything accessible or invokable by ``TicketDetailInteractor``.
extension TicketDetailRouter: TicketDetailRouting {
    
    
    func attachFlowAddWorkReport() {
        let router = crewNewWorkLogBuilder.build(withListener: interactor)
        self.crewNewWorkLogRouter = router
        
        self.attachChild(router)
        self.viewController.present(newFlow: router.viewControllable, completion: nil)
    }
    
    func detachFlowAddWorkReport() {
        if let crewNewWorkLogRouter {
            self.viewController.cleanUp(completion: nil)
            self.detachChild(crewNewWorkLogRouter)
            self.crewNewWorkLogRouter = nil
        }
    }
    
    
    func attachFlowDelegateTicket(ticketId: String, issueType: FPIssueType) {
        let router = crewDelegatingBuilder.build(withListener: interactor, ticketId: ticketId, issueType: issueType)
        self.crewDelegatingRouter = router
        
        self.attachChild(router)
        self.viewController.present(newFlow: router.viewControllable, completion: nil)
    }
    
    func detachFlowDelegateTicket() {
        if let crewDelegatingRouter {
            self.viewController.cleanUp(completion: nil)
            self.detachChild(crewDelegatingRouter)
            self.crewDelegatingRouter = nil
        }
    }
    
    
    func attachFlowEvaluateWorkReport(logs: [FPTicketLog]) {
        let router = workEvaluatingBuilder.build(withListener: interactor, workLogs: logs)
        self.workEvaluatingRouter = router
        
        self.attachChild(router)
        self.viewController.present(newFlow: router.viewControllable, completion: nil)
    }
    
    func detachFlowEvaluateWorkReport() {
        if let workEvaluatingRouter {
            self.viewController.cleanUp(completion: nil)
            self.detachChild(workEvaluatingRouter)
            self.workEvaluatingRouter = nil
        }
    }
    
    
    func attachFlowTicketReport(urlToReport: URL) {
        let router = ticketReportBuilder.build(withListener: interactor, urlToReport: urlToReport)
        self.ticketReportRouter = router
        
        self.attachChild(router)
        self.viewController.present(newFlow: router.viewControllable, completion: nil)
    }
    
    func detachFlowTicketReport() {
        if let ticketReportRouter {
            self.viewController.cleanUp(completion: nil)
            self.detachChild(ticketReportRouter)
            self.ticketReportRouter = nil
        }
    }
    
}
