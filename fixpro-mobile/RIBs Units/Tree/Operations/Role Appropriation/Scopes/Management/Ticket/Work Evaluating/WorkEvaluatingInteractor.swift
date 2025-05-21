import RIBs
import Foundation
import VinUtility
import RxSwift



/// Contract adhered to by ``WorkEvaluatingRouter``, listing the attributes and/or actions 
/// that ``WorkEvaluatingInteractor`` is allowed to access or invoke.
protocol WorkEvaluatingRouting: ViewableRouting {
    func dismiss()
}



/// Contract adhered to by ``WorkEvaluatingViewController``, listing the attributes and/or actions
/// that ``WorkEvaluatingInteractor`` is allowed to access or invoke.
protocol WorkEvaluatingPresentable: Presentable {
    
    
    /// Reference to ``WorkEvaluatingInteractor``.
    var presentableListener: WorkEvaluatingPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: WorkEvaluatingSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `WorkEvaluatingRIB`'s parent, listing the attributes and/or actions
/// that ``WorkEvaluatingInteractor`` is allowed to access or invoke.
protocol WorkEvaluatingListener: AnyObject {
    func didDismissWorkEvaluating()
    func didEvaluateWork(log: FPTicketLog)
}



/// The functionality centre of `WorkEvaluatingRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class WorkEvaluatingInteractor: PresentableInteractor<WorkEvaluatingPresentable>, WorkEvaluatingInteractable {
    
    
    /// Reference to ``WorkEvaluatingRouter``.
    weak var router: WorkEvaluatingRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: WorkEvaluatingListener?
    
    
    /// Reference to the component of this RIB.
    var component: WorkEvaluatingComponent
    
    
    /// Bridge to the ``WorkEvaluatingSwiftUIVIew``.
    private var viewModel = WorkEvaluatingSwiftUIViewModel()
    
    
    var logs: [FPTicketLog]
    
    
    /// Constructs an instance of ``WorkEvaluatingInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: WorkEvaluatingComponent, workLogs: [FPTicketLog]) {
        self.component = component
        self.logs = workLogs
        
        let presenter = component.workEvaluatingViewController
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
        viewModel.workProgressLogs = logs
        viewModel.didIntendToDismiss = { [weak self] in
            self?.router?.dismiss()
        }
        viewModel.didIntendToApprove = { [weak self] in 
            self?.approve()
        }
        viewModel.didIntendToReject = { [weak self] in 
            self?.reject()
        }
        presenter.bind(viewModel: self.viewModel)
    }
    
}



extension WorkEvaluatingInteractor {
    
    
    enum ValidationError: String, Error {
        case MISSING_REASON = "Do let your colleagues know what could be improved."
    }
    
    private func approve() {
        Task {
            let attemptedRequest = try await makeRequest(news: "Work was approved.", 
                                                         attachments: [], 
                                                         logType: .init(stringLiteral: "Work Evaluation"))
            switch attemptedRequest {
                case .created(let made):
                    viewModel.reset()
                    DispatchQueue.main.sync {
                        self.router?.dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.router?.dismiss()
                        }
                    }
                    
                    do {
                        let response = try made.body.json
                        let encoder = JSONEncoder()
                        let encodedData = try encoder.encode(response.data)
                        let decodedData = try decode(encodedData, to: FPTicketLog.self).get()
                        listener?.didEvaluateWork(log: decodedData)
                    } catch {
                        VULogger.log(tag: .error, error)
                    }
                    
                    break
                case .undocumented(statusCode: let code, let payload):
                    VULogger.log(tag: .error, code, payload)
            }
        }
    }
    
    
    private func reject() {
        if case let .failure(errorMessage) = validate() {
            viewModel.validationMessage = errorMessage.rawValue
            return
        }
        
        Task {
            let attemptedRequest = try await makeRequest(news: viewModel.rejectionReason, 
                                                         attachments: [], 
                                                         logType: .init(stringLiteral: "Work Progress"))
            switch attemptedRequest {
                case .created(let made):
                    viewModel.reset()
                    DispatchQueue.main.sync {
                        self.router?.dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.router?.dismiss()
                        }
                    }
                    
                    do {
                        let response = try made.body.json
                        let encoder = JSONEncoder()
                        let encodedData = try encoder.encode(response.data)
                        let decodedData = try decode(encodedData, to: FPTicketLog.self).get()
                        listener?.didEvaluateWork(log: decodedData)
                    } catch {
                        VULogger.log(tag: .error, error)
                    }
                    
                    break
                case .undocumented(statusCode: let code, let payload):
                    VULogger.log(tag: .error, code, payload)
            }
        }
    }
    
    
    private func validate() -> Result<Void, ValidationError> {
        guard !viewModel.rejectionReason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .failure(.MISSING_REASON)
        }
        
        return .success(())
    }
    
    
    private func makeRequest(news: String, attachments: [Components.Schemas.TOBEMADE_hyphen_supportive_hyphen_document]?, logType: Components.Schemas.ticket_hyphen_log_hyphen_type) async throws -> Operations.postTicketLog.Output {
        try await self.component.networkingClient.gateway.postTicketLog(.init(
            path: .init(ticket_id: self.logs.first?.id ?? ""),
            headers: .init(accept: [.init(contentType: .json)]),
            body: .json(.init(
                data: .init(
                    news: news, 
                    supportive_documents: attachments, 
                    _type: logType
                )
            ))
        ))
    }
    
}



/// Conformance to the ``WorkEvaluatingPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``WorkEvaluatingViewController``.
extension WorkEvaluatingInteractor: WorkEvaluatingPresentableListener {
    func didGetDismissed() {
        listener?.didDismissWorkEvaluating()
    }
}
