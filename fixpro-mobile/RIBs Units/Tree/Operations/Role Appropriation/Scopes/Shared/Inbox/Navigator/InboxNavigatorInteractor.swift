import Foundation
import RIBs
import RxSwift
import UIKit
import VinUtility



/// Contract adhered to by ``InboxNavigatorRouter``, listing the attributes and/or actions 
/// that ``InboxNavigatorInteractor`` is allowed to access or invoke.
protocol InboxNavigatorRouting: ViewableRouting {
        
    
    /// Cleanses the view hierarchy of any `ViewControllable` instances this RIB may have added.
    func cleanupViews()
    
    
    func deeplinkTo(ticket: FPTicketDetail)
    
    
    func deeplinkTo(ticketLog: FPTicketLog)
    
    
    func navigateToMailList()
    
    
    func navigateBackToTicketDetail()
    
}



/// Contract adhered to by ``InboxNavigatorViewController``, listing the attributes and/or actions
/// that ``InboxNavigatorInteractor`` is allowed to access or invoke.
protocol InboxNavigatorPresentable: Presentable {
    
    
    /// Reference to ``InboxNavigatorInteractor``.
    var presentableListener: InboxNavigatorPresentableListener? { get set }
    
}



/// Contract adhered to by the Interactor of `InboxNavigatorRIB`'s parent, listing the attributes and/or actions
/// that ``InboxNavigatorInteractor`` is allowed to access or invoke.
protocol InboxNavigatorListener: AnyObject {}



/// The functionality centre of `InboxNavigatorRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class InboxNavigatorInteractor: PresentableInteractor<InboxNavigatorPresentable>, InboxNavigatorInteractable {
    
    
    /// Reference to ``InboxNavigatorRouter``.
    weak var router: InboxNavigatorRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: InboxNavigatorListener?
    
    
    /// Reference to the component of this RIB.
    var component: InboxNavigatorComponent
    
    
    /// Constructs an instance of ``InboxNavigatorInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: InboxNavigatorComponent) {
        self.component = component
        let presenter = component.inboxNavigatorNavigationController
        
        super.init(presenter: presenter)
        
        presenter.presentableListener = self
    }
    
    
    /// Customization point that is invoked after self becomes active.
    override func didBecomeActive() {
        super.didBecomeActive()
    }
    
    
    /// Customization point that is invoked before self is fully detached.
    override func willResignActive() {
        super.willResignActive()
        router?.cleanupViews()
    }
    
}



extension InboxNavigatorInteractor {
    
    
    func didTap(notification: FPNotificationDigest) {
        if case .SEGUE = notification.actionable.genus,
           case .TICKET = notification.actionable.species,
           let encodedTicketPayload = notification.actionable.destination
        {
            do {
                let ticket = try decode(encodedTicketPayload.data(using: .utf8)!, to: VUExtrasPreservingDecodable<FPTicketDetail>.self).get()
                let t = FPTicketDetail(id: ticket.model.id, issueTypes: ticket.model.issueTypes, responseLevel: ticket.model.responseLevel, raisedOn: ticket.model.raisedOn, status: ticket.model.status, statedIssue: ticket.model.statedIssue, location: ticket.model.location, supportiveDocuments: ticket.model.supportiveDocuments, issuer: ticket.model.issuer, logs: ticket.model.logs, handlers: ticket.model.handlers)
                router?.deeplinkTo(ticket: t)
                
            } catch {
                // Nothing bad will happen when there's a decode failure.
                // Simply log them.
                VULogger.log(tag: .error, error)
            }
            
        }
        else if case .SEGUE = notification.actionable.genus,
                case .TICKET_LOG = notification.actionable.species,
                let encodedTicketLogPayload = notification.actionable.destination
        {
            do {
                let encoder = JSONEncoder()
                let encodedTicket = try encoder.encode(encodedTicketLogPayload)
                let ticketLog = try decode(encodedTicket, to: FPTicketLog.self).get()
                router?.deeplinkTo(ticketLog: ticketLog)
                
            } catch {
                // Nothing bad will happen when there's a decode failure.
                // Simply log them.
                VULogger.log(tag: .error, error)
            }
        }
    }
    
    
    func navigateTo(ticketLog: FPTicketLog) {
        router?.deeplinkTo(ticketLog: ticketLog)
    }
    
    
    func navigateBack() {
        router?.navigateToMailList()
    }
    
    
    func navigateBackToTicketDetail() {
        router?.navigateBackToTicketDetail()
    }
    
}



/// Conformance to the ``InboxNavigatorPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``InboxNavigatorViewController``.
extension InboxNavigatorInteractor: InboxNavigatorPresentableListener {}
