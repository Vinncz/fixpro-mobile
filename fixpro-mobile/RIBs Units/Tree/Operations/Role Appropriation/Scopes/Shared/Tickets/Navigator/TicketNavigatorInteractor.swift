import RIBs
import UIKit
import Foundation
import VinUtility
import RxSwift



/// Contract adhered to by ``TicketNavigatorRouter``, listing the attributes and/or actions 
/// that ``TicketNavigatorInteractor`` is allowed to access or invoke.
protocol TicketNavigatorRouting: ViewableRouting {
        
    
    /// Cleanses the view hierarchy of any `ViewControllable` instances this RIB may have added.
    func cleanupViews()
    
    
    
    
    var ticketListRouter: TicketListsRouting? { get }
    
    
    func flowTo(ticketId: String)
    
    
    /// Invoked only through notification deeplinks.
    func flowTo(ticket: FPTicketDetail)
    
    
    /// Invoked only through notification deeplinks.
    func flowTo(ticketLog: FPTicketLog)
    
    
    func navigateToTicketList()
    
    
    func backToTicketDetail()
    
}



/// Contract adhered to by ``TicketNavigatorViewController``, listing the attributes and/or actions
/// that ``TicketNavigatorInteractor`` is allowed to access or invoke.
protocol TicketNavigatorPresentable: Presentable {
    
    
    /// Reference to ``TicketNavigatorInteractor``.
    var presentableListener: TicketNavigatorPresentableListener? { get set }
    
}



/// Contract adhered to by the Interactor of `TicketNavigatorRIB`'s parent, listing the attributes and/or actions
/// that ``TicketNavigatorInteractor`` is allowed to access or invoke.
protocol TicketNavigatorListener: AnyObject {}



/// The functionality centre of `TicketNavigatorRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class TicketNavigatorInteractor: PresentableInteractor<TicketNavigatorPresentable>, TicketNavigatorInteractable {
    
    
    /// Reference to ``TicketNavigatorRouter``.
    weak var router: TicketNavigatorRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: TicketNavigatorListener?
    
    
    /// Reference to the component of this RIB.
    var component: TicketNavigatorComponent
    
    
    /// Constructs an instance of ``TicketNavigatorInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: TicketNavigatorComponent) {
        self.component = component
        let presenter = component.ticketNavigatorNavigationController
        
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



extension TicketNavigatorInteractor {
    
    
    func navigateTo(ticketDetail: FPTicketDetail) {
        router?.flowTo(ticket: ticketDetail)
    }
    
    
    func navigateToTicketDetail(forId ticketId: String) {
        router?.flowTo(ticketId: ticketId)
    }
    
    
    func navigateTo(ticketLog: FPTicketLog) {
        router?.flowTo(ticketLog: ticketLog)
    }
    
    
    func navigateBack() {
        router?.navigateToTicketList()
    }
    
    
    func navigateBackToTicketDetail() {
        router?.backToTicketDetail()
    }
    
    
    func fetchTicketDetail(forId ticketId: String) async -> Result<FPTicketDetail, FPError> {
        do {
            let attemptedRequest = try await component.networkingClient.gateway.getTicket(.init(
                path: .init(ticket_id: ticketId),
                headers: .init(accept: [.init(contentType: .json)])
            ))
            
            switch attemptedRequest {
                case .ok(let response):
                    let encoder = JSONEncoder()
                    let encodedData = try encoder.encode(response.body.json.data)
                    let decodedData = try decode(encodedData, to: FPTicketDetail.self).get()
                    
                    return .success(decodedData)
                    
                case .badRequest:
                    VULogger.log(tag: .error, "BAD REQUEST FOR TICKET DETAIL")
                    return .failure(.BAD_REQUEST)
                    
                case .undocumented(statusCode: let code, let payload):
                    VULogger.log(tag: .error, "UNDOCUMENTED FOR TICKET DETAIL \(code) -- \(payload)")
                    return .failure(.UNEXPECTED_RESPONSE)
            }
            
        } catch {
            VULogger.log(tag: .network, "UNREACHABLE \(error)")
            return .failure(.UNREACHABLE)
            
        }
    }
    
}




/// Conformance to the ``TicketNavigatorPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``TicketNavigatorViewController``.
extension TicketNavigatorInteractor: TicketNavigatorPresentableListener {}
