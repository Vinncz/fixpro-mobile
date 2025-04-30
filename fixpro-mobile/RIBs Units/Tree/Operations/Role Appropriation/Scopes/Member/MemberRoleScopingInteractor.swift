import RIBs
import Foundation
import VinUtility
import RxSwift



/// Contract adhered to by ``MemberRoleScopingRouter``, listing the attributes and/or actions 
/// that ``MemberRoleScopingInteractor`` is allowed to access or invoke.
protocol MemberRoleScopingRouting: ViewableRouting {
    var ticketNavigatorRouter: TicketNavigatorRouting? { get }
}



/// Contract adhered to by ``MemberRoleScopingViewController``, listing the attributes and/or actions
/// that ``MemberRoleScopingInteractor`` is allowed to access or invoke.
protocol MemberRoleScopingPresentable: Presentable {
    
    
    /// Reference to ``MemberRoleScopingInteractor``.
    var presentableListener: MemberRoleScopingPresentableListener? { get set }
    
}



/// Contract adhered to by the Interactor of `MemberRoleScopingRIB`'s parent, listing the attributes and/or actions
/// that ``MemberRoleScopingInteractor`` is allowed to access or invoke.
protocol MemberRoleScopingListener: AnyObject {
    func didIntendToLogOut()
}



/// The functionality centre of `MemberRoleScopingRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class MemberRoleScopingInteractor: PresentableInteractor<MemberRoleScopingPresentable>, MemberRoleScopingInteractable {
    
    
    /// Reference to ``MemberRoleScopingRouter``.
    weak var router: MemberRoleScopingRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: MemberRoleScopingListener?
    
    
    /// Reference to the component of this RIB.
    var component: MemberRoleScopingComponent
    
    
    /// Others.
    var triggerNotification: FPNotificationDigest?
    
    
    /// Constructs an instance of ``MemberRoleScopingInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: MemberRoleScopingComponent, presenter: MemberRoleScopingPresentable, triggerNotification: FPNotificationDigest?) {
        self.component = component
        self.triggerNotification = triggerNotification
        
        super.init(presenter: presenter)
        
        presenter.presentableListener = self
    }
    
    
    /// Customization point that is invoked after self becomes active.
    override func didBecomeActive() {
        super.didBecomeActive()
        
        if case .SEGUE = triggerNotification?.actionable.genus,
           case .TICKET = triggerNotification?.actionable.species,
           let encodedTicketPayload = triggerNotification?.actionable.destination
        {
            do {
                let encoder = JSONEncoder()
                let encodedTicket = try encoder.encode(encodedTicketPayload)
                let ticket = try decode(encodedTicket, to: FPTicketDetail.self).get()
                router?.ticketNavigatorRouter?.flowTo(ticket: ticket)
                
            } catch {
                // Nothing bad will happen when there's a decode failure.
                // Simply log them.
                VULogger.log(tag: .error, error)
            }
            
        }
        else if case .SEGUE = triggerNotification?.actionable.genus,
                case .TICKET_LOG = triggerNotification?.actionable.species,
                let encodedTicketLogPayload = triggerNotification?.actionable.destination
        {
            do {
                let encoder = JSONEncoder()
                let encodedTicket = try encoder.encode(encodedTicketLogPayload)
                let ticketLog = try decode(encodedTicket, to: FPTicketLog.self).get()
                router?.ticketNavigatorRouter?.flowTo(ticketLog: ticketLog)
                
            } catch {
                // Nothing bad will happen when there's a decode failure.
                // Simply log them.
                VULogger.log(tag: .error, error)
            }
        }
    }
    
    
    /// Customization point that is invoked before self is detached.
    override func willResignActive() {
        super.willResignActive()
    }
    
    
    deinit {
        VULogger.log("Will resign active")
    }
    
}



extension MemberRoleScopingInteractor {
    
    
    func didIntendToLogOut() {
        listener?.didIntendToLogOut()
    }
    
    
    func didRaise(ticket: FPLightweightIssueTicket) {
        (router?.ticketNavigatorRouter?.ticketListRouter?.interactable as? TicketListsInteractable)?.didMake(ticket: ticket)
        VULogger.log("Did talk to ticket list router")
    }
    
}



/// Conformance to the ``MemberRoleScopingPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``MemberRoleScopingViewController``
extension MemberRoleScopingInteractor: MemberRoleScopingPresentableListener {}
