import Foundation
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
    
    
    func attachFlowEvaluateWorkReport(logs: [FPTicketLog])
    func detachFlowEvaluateWorkReport()
    
    
    func attachFlowTicketReport(urlToReport: URL)
    func detachFlowTicketReport()
    
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
    
    
    /// Others.
    var ticket: FPTicketDetail?
    var ticketId: String?
    
    
    /// Constructs an instance of ``TicketDetailInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: TicketDetailComponent, presenter: TicketDetailPresentable, ticket: FPTicketDetail? = nil, ticketId: String?) {
        self.ticket = ticket
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
        
        if let ticket {
            viewModel.id = ticket.id
            viewModel.location = ticket.location
            viewModel.supportiveDocuments = ticket.supportiveDocuments
            viewModel.status = ticket.status
            viewModel.statedIssue = ticket.statedIssue
            viewModel.handlers = ticket.handlers.map {
                var mod = $0.model
                mod.extras = $0.extrasAsStringMap()
                return mod
            }
            viewModel.issueTypes = ticket.issueTypes
            viewModel.logs = ticket.logs
            viewModel.raisedOn = ticket.raisedOn
            viewModel.closedOn = ticket.closedOn
            viewModel.responseLevel = ticket.responseLevel
            viewModel.executiveSummary = ticket.executiveSummary
            
            Task { @MainActor in
                presenter.updateToolbar()
            }
        }
        
        if let ticketId {
            Task { @MainActor in
                await updateViewModelAttributes(ticketId: ticketId)
            }
        }
        
        viewModel.didTapTicketLog = { [weak self] ticketLog in
            self?.listener?.navigateTo(ticketLog: ticketLog)
        }
        
        viewModel.didIntedToRefresh = { [weak self] in
            await self?.updateViewModelAttributes(ticketId: self!.viewModel.id!)
        }
        
        presenter.bind(viewModel: self.viewModel)
    }
    
}



extension TicketDetailInteractor {
    
    
    func didAdd(log: FPTicketLog) {
        viewModel.logs.append(log)
        if log.type == .workEvaluationRequest {
            viewModel.status = .workEvaluation
        }
    }
    
    
    func didAdd(handlers: [FPPerson]) {
        viewModel.handlers.append(contentsOf: handlers)
    }
    
    
    func didEvaluateWork(log: FPTicketLog) {
        viewModel.logs.append(log)
    }
    
}



extension TicketDetailInteractor {
    
    
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
                    
                    self.ticket = decodedData
                    
                    return .success(decodedData)
                    
                case .undocumented(statusCode: let code, let payload):
                    VULogger.log(tag: .error, "UNDOCUMENTED FOR TICKET DETAIL \(code) -- \(payload)")
                    return .failure(.UNEXPECTED_RESPONSE)
            }
            
        } catch {
            VULogger.log(tag: .network, "UNREACHABLE \(error)")
            return .failure(.UNREACHABLE)
            
        }
    }
    
    
    func updateViewModelAttributes(ticketId: String) async {
        if let ticket = try? await fetchTicketDetail(forId: ticketId).get() {
            viewModel.id = ticket.id
            viewModel.location = ticket.location
            viewModel.supportiveDocuments = ticket.supportiveDocuments
            viewModel.status = ticket.status
            viewModel.statedIssue = ticket.statedIssue
            viewModel.handlers = ticket.handlers.map {
                var mod = $0.model
                mod.extras = $0.extrasAsStringMap()
                return mod
            }
            viewModel.issueTypes = ticket.issueTypes
            viewModel.logs = ticket.logs
            viewModel.raisedOn = ticket.raisedOn
            viewModel.closedOn = ticket.closedOn
            viewModel.responseLevel = ticket.responseLevel
            viewModel.executiveSummary = ticket.executiveSummary
            
            Task { @MainActor in
                presenter.updateToolbar()
            }
            
            self.ticket = ticket
        }
    }
    
}



/// Conformance to the ``TicketDetailPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``TicketDetailViewController``.
extension TicketDetailInteractor: TicketDetailPresentableListener {
    
    
    func navigateBack() {
        listener?.navigateBack()
    }
    
    
    func didIntedToCloseTicket() {
        Task {
            if case .member = component.authorizationContext.role {
                let attemptedRequest = try await component.networkingClient.gateway.postCancelTicket(.init(path: .init(ticket_id: ticket!.id), headers: .init(accept: [.init(contentType: .json)])))
                switch attemptedRequest {
                    case .ok:
                        await updateViewModelAttributes(ticketId: ticket!.id)
                        viewModel.status = .cancelled
                        viewModel.closedOn = Date.now.ISO8601Format()
                        
                    case .undocumented(statusCode: let code, let payload):
                        VULogger.log(tag: .error, code, payload)
                }
                
            } else {
                let attemptedRequest = try await component.networkingClient.gateway.postRejectTicket(.init(
                    path: .init(ticket_id: ticket!.id), 
                    headers: .init(accept: [.init(contentType: .json)]), 
                    body: .json(.init(reason: viewModel.rejectionReason))
                ))
                switch attemptedRequest {
                    case .ok:
                        await updateViewModelAttributes(ticketId: ticket!.id)
                        viewModel.status = .rejected
                        viewModel.closedOn = Date.now.ISO8601Format()
                        
                    case .undocumented(statusCode: let code, let payload):
                        VULogger.log(tag: .error, code, payload)
                }
                
            }
        }
    }
    
}



extension TicketDetailInteractor {
    
    
    func didIntendToAddWorkReport() {
        router?.attachFlowAddWorkReport(ticketId: viewModel.id!)
    }
    
    
    func didIntendToDelegateTicket() {
        router?.attachFlowDelegateTicket(ticket: ticket!)
    }
    
    
    func didIntendToEvaluateWorkReport() {
        let workRelatedLogs = viewModel.logs.filter { [.workEvaluationRequest, .workProgress].contains($0.type) }
        guard workRelatedLogs.count > 0 else {
            VULogger.log(tag: .warning, "No work-related logs. This shouldn't be happening.")
            return
        }
        
        router?.attachFlowEvaluateWorkReport(logs: workRelatedLogs)
    }
    
    
    func didIntendToSeeTicketReport() {
        router?.attachFlowTicketReport(urlToReport: URL(string: component.networkingClient.endpoint.absoluteString + "/ticket/\(viewModel.id!)/report")!)
    }
    
}



extension TicketDetailInteractor {
    
    
    func didDismissCrewDelegating() {
        router?.detachFlowDelegateTicket()
    }
    
    
    func didDismissTicketReport() {
        router?.detachFlowTicketReport()
    }
    
    
    func didDismissWorkEvaluating() {
        router?.detachFlowEvaluateWorkReport()
    }
    
    
    func didDismissCrewNewWorkLog() {
        router?.detachFlowAddWorkReport()
    }
    
}
