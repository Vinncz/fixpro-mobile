import Foundation
import UniformTypeIdentifiers
import RIBs
import RxSwift
import VinUtility



/// Contract adhered to by ``TicketDetailRouter``, listing the attributes and/or actions 
/// that ``TicketDetailInteractor`` is allowed to access or invoke.
protocol TicketDetailRouting: ViewableRouting {
    
    
    func attachFlowAddWorkReport(ticketId: String)
    func detachFlowAddWorkReport()
    
    
    func attachFlowDelegateTicket(ticket: FPTicketDetail)
    func detachFlowDelegateTicket()
    
    
    func attachFlowInviteTicket(ticket: FPTicketDetail)
    func detachFlowInviteTicket()
    
    
    func attachFlowWorkEvaluating(ticket: FPTicketDetail)
    func detachWorkEvaluating()
    
}



/// Contract adhered to by ``TicketDetailViewController``, listing the attributes and/or actions
/// that ``TicketDetailInteractor`` is allowed to access or invoke.
protocol TicketDetailPresentable: Presentable {
    
    
    /// Reference to ``TicketDetailInteractor``.
    var presentableListener: TicketDetailPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: TicketDetailSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
    
    func updateToolbar()
    
}



/// Contract adhered to by the Interactor of `TicketDetailRIB`'s parent, listing the attributes and/or actions
/// that ``TicketDetailInteractor`` is allowed to access or invoke.
protocol TicketDetailListener: AnyObject {
    
    
    func navigateTo(ticketLog: FPTicketLog)
    
    
    func navigateBack()
    
}



/// The functionality centre of `TicketDetailRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class TicketDetailInteractor: PresentableInteractor<TicketDetailPresentable>, TicketDetailInteractable {
    
    
    
    /// Reference to ``TicketDetailRouter``.
    weak var router: TicketDetailRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: TicketDetailListener?
    
    
    /// Reference to the component of this RIB.
    var component: TicketDetailComponent
    
    
    var viewModel: TicketDetailSwiftUIViewModel
    
    
    /// Available if navigated here via Inbox.
    var ticket: FPTicketDetail?
    
    
    /// Available if navigated here via Ticket List.
    var ticketId: String?
    
    
    /// Constructs an instance of ``TicketDetailInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: TicketDetailComponent, presenter: TicketDetailPresentable, ticket: FPTicketDetail? = nil, ticketId: String?) {
        self.component = component
        self.ticket = ticket
        self.ticketId = ticketId
        self.viewModel = .init(role: component.authorizationContext.role)
        
        super.init(presenter: presenter)
        
        presenter.presentableListener = self
    }
    
    
    deinit {
        VULogger.log("Deinitialized.")
    }
    
    
    /// Customization point that is invoked after self becomes active.
    override func didBecomeActive() {
        super.didBecomeActive()
        configureViewModel()
    }
    
    
    /// Customization point that is invoked before self is fully detached.
    override func willResignActive() {
        super.willResignActive()
    }
    
    
    /// Configures the view model.
    private func configureViewModel() {
        viewModel.role = component.authorizationContext.role
        viewModel.baseURL = component.networkingClient.endpoint
        
        if let ticket {
            viewModel.ticket = ticket
            Task { @MainActor in presenter.updateToolbar() }
        } else if let ticketId {
            Task { [weak self] in
                if let ticket = try await self?.fetchTicketDetails(ticketId: ticketId) {
                    self?.viewModel.ticket = ticket
                    Task { @MainActor in self?.presenter.updateToolbar() }
                }
            }
        }
        
        viewModel.didTapTicketLog = { [weak self] ticketLog in
            self?.listener?.navigateTo(ticketLog: ticketLog)
        }
        viewModel.didIntedToRefresh = { [weak self] in
            if let ticket = self?.viewModel.ticket {
                if let newTicket = try await self?.fetchTicketDetails(ticketId: ticket.id) {
                    self?.viewModel.ticket = newTicket
                    Task { @MainActor in self?.presenter.updateToolbar() }
                }
            }
        }
        
        viewModel.didCancelTicket = { [weak self] in
            let topMostViewController = await topMostViewController()
            await VUPresentLoadingAlert(
                on: topMostViewController,
                title: "Cancelling ticket...", 
                message: "This action shoudn't take more than 15 seconds.", 
                cancelButtonCTA: "Cancel", 
                delay: 15, 
                cancelAction: {}
            )
            
            if
                try await self?.didIntendToCancelTicket() == true, 
                let ticket = self?.viewModel.ticket
            {
                if let newTicket = try await self?.fetchTicketDetails(ticketId: ticket.id) {
                    self?.viewModel.ticket = newTicket
                    Task { @MainActor in 
                        self?.presenter.updateToolbar() 
                        topMostViewController?.dismiss(animated: true)
                    }
                }
            }
        }
        viewModel.didRejectTicket = { [weak self] (reason: String, supportiveDocuments: [URL]) in
            let topMostViewController = await topMostViewController()
            await VUPresentLoadingAlert(
                on: topMostViewController,
                title: "Rejecting ticket...", 
                message: "Your progress is saved. This shoudn't take more than 15 seconds.", 
                cancelButtonCTA: "Cancel", 
                delay: 15, 
                cancelAction: {}
            )
            
            if 
                try await self?.didIntendToRejectTicket(reason: reason, supportiveDocuments: supportiveDocuments) == true,
                let ticket = self?.viewModel.ticket
            {
                if let newTicket = try await self?.fetchTicketDetails(ticketId: ticket.id) {
                    self?.viewModel.ticket = newTicket
                    Task { @MainActor in 
                        self?.presenter.updateToolbar() 
                        topMostViewController?.dismiss(animated: true)
                    }
                }
            }
        }
        
        presenter.bind(viewModel: self.viewModel)
    }
    
}



/// Conformance to the ``TicketDetailPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``TicketDetailViewController``.
extension TicketDetailInteractor: TicketDetailPresentableListener {
    
    
    func navigateBack() {
        listener?.navigateBack()
    }
    
}



extension TicketDetailInteractor {
    
    
    func fetchTicketDetails(ticketId: String) async throws -> FPTicketDetail? {
        async let request = component.networkingClient.gateway.getTicket(.init(
            path: .init(ticket_id: ticketId), 
            headers: .init(accept: [.init(contentType: .json)])
        ))
        
        switch try await request {
            case let .ok(response):
                if case let .json(body) = response.body {
                    let encoder = JSONEncoder()
                    let encodedData = try encoder.encode(body.data)
                    let decodedData = try decode(encodedData, to: FPTicketDetail.self).get()
                    
                    return decodedData
                }
            case .undocumented(statusCode: let code, let payload):
                VULogger.log(tag: .network, code, payload)
        }
        
        return nil
    }
    
    
    func didIntendToCancelTicket() async throws -> Bool {
        guard let ticket = viewModel.ticket else { return false }
        
        async let request = component.networkingClient.gateway.postTicketClosure(.init(
            path: .init(ticket_id: ticket.id),
            headers: .init(accept: [.init(contentType: .json)]),
            body: .json(.init(data: .init(
                reason: "",
                supportive_documents: []
            )))
        ))
        
        switch try await request {
            case .ok:
                return true
            case .undocumented(statusCode: let code, let payload):
                VULogger.log(tag: .network, code, payload)
        }
        
        return false
    }
    
    
    func didIntendToRejectTicket(reason: String, supportiveDocuments: [URL]) async throws -> Bool {
        guard let ticket = viewModel.ticket else { return false }
        
        let attachments = supportiveDocuments.map { file in Components.Schemas.TOBEMADE_hyphen_supportive_hyphen_document(
            resource_type: .init(stringLiteral: UTType(file.pathExtension)?.preferredMIMEType ?? UTType.data.preferredMIMEType ?? "application/octet-stream"),
            resource_name: file.lastPathComponent,
            resource_size: Double(inferFileSize(from: file) ?? 0), 
            resource_content: fileToBase64(on: file)
        )}
        
        async let request = component.networkingClient.gateway.postTicketClosure(.init(
            path: .init(ticket_id: ticket.id),
            headers: .init(accept: [.init(contentType: .json)]),
            body: .json(.init(data: .init(
                reason: reason,
                supportive_documents: attachments
            )))
        ))
        
        switch try await request {
            case .ok:
                return true
            case .undocumented(statusCode: let code, let payload):
                VULogger.log(tag: .network, code, payload)
        }
        
        return false
    }
    
}



/// Router coordination extension.
extension TicketDetailInteractor {
    
    
    func didIntendToContribute() {
        if let ticket = viewModel.ticket {
            router?.attachFlowAddWorkReport(ticketId: ticket.id)
        }
    }
    func dismissUpdateContributing(didContribute: Bool) {
        router?.detachFlowAddWorkReport()
        if didContribute {
            Task { [weak self] in
                if let ticket = self?.viewModel.ticket, let newTicket = try await self?.fetchTicketDetails(ticketId: ticket.id) {
                    self?.viewModel.ticket = newTicket
                    Task { @MainActor in 
                        self?.presenter.updateToolbar() 
                    }
                }
            }
        }
    }
    
    
    func didIntendToDelegateTicket() {
        if let ticket = viewModel.ticket {
            router?.attachFlowDelegateTicket(ticket: ticket)
        }
    }
    func dismissCrewDelegating(didDelegate: Bool) {
        router?.detachFlowDelegateTicket()
        if didDelegate {
            Task { [weak self] in
                if let ticket = self?.viewModel.ticket, let newTicket = try await self?.fetchTicketDetails(ticketId: ticket.id) {
                    self?.viewModel.ticket = newTicket
                    Task { @MainActor in 
                        self?.presenter.updateToolbar() 
                    }
                }
            }
        }
    }
    
    
    
    func didIntendToInviteTicket() {
        if let ticket = viewModel.ticket {
            router?.attachFlowInviteTicket(ticket: ticket)
        }
    }
    func dismissCrewInviting(didInvite: Bool) {
        router?.detachFlowInviteTicket()
        if didInvite {
            Task { [weak self] in
                if let ticket = self?.viewModel.ticket, let newTicket = try await self?.fetchTicketDetails(ticketId: ticket.id) {
                    self?.viewModel.ticket = newTicket
                    Task { @MainActor in 
                        self?.presenter.updateToolbar() 
                    }
                }
            }
        }
    }
    
    
    
    func didIntendToEvaluateWork() {
        if let ticket = viewModel.ticket {
            router?.attachFlowWorkEvaluating(ticket: ticket)
        }
    }
    func detachWorkEvaluating(didEvaluate: Bool) {
        router?.detachWorkEvaluating()
        if didEvaluate {
            Task { [weak self] in
                if let ticket = self?.viewModel.ticket, let newTicket = try await self?.fetchTicketDetails(ticketId: ticket.id) {
                    self?.viewModel.ticket = newTicket
                    Task { @MainActor in 
                        self?.presenter.updateToolbar() 
                    }
                }
            }
        }
    }
    
}
