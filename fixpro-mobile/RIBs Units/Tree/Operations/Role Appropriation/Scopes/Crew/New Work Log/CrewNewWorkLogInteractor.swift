import OpenAPIRuntime
import UniformTypeIdentifiers
import RIBs
import RxSwift
import VinUtility



/// Contract adhered to by ``CrewNewWorkLogRouter``, listing the attributes and/or actions 
/// that ``CrewNewWorkLogInteractor`` is allowed to access or invoke.
protocol CrewNewWorkLogRouting: ViewableRouting {
    func dismiss()
}



/// Contract adhered to by ``CrewNewWorkLogViewController``, listing the attributes and/or actions
/// that ``CrewNewWorkLogInteractor`` is allowed to access or invoke.
protocol CrewNewWorkLogPresentable: Presentable {
    
    
    /// Reference to ``CrewNewWorkLogInteractor``.
    var presentableListener: CrewNewWorkLogPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: CrewNewWorkLogSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `CrewNewWorkLogRIB`'s parent, listing the attributes and/or actions
/// that ``CrewNewWorkLogInteractor`` is allowed to access or invoke.
protocol CrewNewWorkLogListener: AnyObject {
    func didDismissCrewNewWorkLog()
    func didAdd(log: FPTicketLog)
}



/// The functionality centre of `CrewNewWorkLogRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class CrewNewWorkLogInteractor: PresentableInteractor<CrewNewWorkLogPresentable>, CrewNewWorkLogInteractable {
    
    
    /// Reference to ``CrewNewWorkLogRouter``.
    weak var router: CrewNewWorkLogRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: CrewNewWorkLogListener?
    
    
    /// Reference to the component of this RIB.
    var component: CrewNewWorkLogComponent
    
    
    /// Bridge to the ``CrewNewWorkLogSwiftUIVIew``.
    private var viewModel = CrewNewWorkLogSwiftUIViewModel()
    
    
    var ticketId: String
    
    
    /// Constructs an instance of ``CrewNewWorkLogInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: CrewNewWorkLogComponent, ticketId: String) {
        self.component = component
        self.ticketId = ticketId
        let presenter = component.crewNewWorkLogViewController
        
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
        viewModel.didIntendToDismiss = { [weak self] in
            self?.router?.dismiss()
        }
        viewModel.didIntendToAddWorkLog = { [weak self] in 
            self?.submit()
        }
        presenter.bind(viewModel: self.viewModel)
    }
    
}



extension CrewNewWorkLogInteractor {
    
    
    enum ValidationError: String, Error {
        case MISSING_UPDATE_TYPE = "Do select the **update type**."
        case UNTYPED_WORK_DESC = "Do specify what was done."
        case NO_DOCUMENTS = "No **work documentations** were attached."
        case FILE_TOO_LARGE = "One or more files are above the **10MB limit**."
    }
    
    
    private func submit() {
        if case .failure(let error) = validate() { 
            viewModel.validationLabel = error.rawValue
            return 
        }
        
        VUPresentLoadingAlert(
            on: router?.viewControllable.uiviewController,
            title: "Submitting your contribution", 
            message: "This shouldn't take more than a minute. Should you cancel this submission, your progress is saved.", 
            cancelButtonCTA: "Cancel", 
            delay: 30, 
            cancelAction: {}
        )
        
        Task {
            let attachments = viewModel.selectedFiles.map { file in Components.Schemas.TOBEMADE_hyphen_supportive_hyphen_document(
                resource_type: .init(stringLiteral: UTType(file.pathExtension)?.preferredMIMEType ?? UTType.data.preferredMIMEType ?? "application/octet-stream"),
                resource_name: file.lastPathComponent,
                resource_size: Double(inferFileSize(from: file) ?? 0), 
                resource_content: fileToBase64(on: file)
            )}
            let attemptedSubmission = try await component.networkingClient.gateway.postTicketLog(.init(
                path: .init(ticket_id: ticketId),
                headers: .init(accept: [.init(contentType: .json)]),
                body: .json(.init(data: .init(
                    news: viewModel.news,
                    supportive_documents: attachments,
                    _type: .init(stringLiteral: viewModel.logType.rawValue)
                )))
            ))
            
            switch attemptedSubmission {
                case .created(let made):
                    VULogger.log("Did contribute work log")
                    viewModel.reset()
                    
                    DispatchQueue.main.sync {
                        self.router?.dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.router?.dismiss()
                        }
                    }
                    
                    let response = try made.body.json
                    talkBackToParentAfterAssemblingLogResponse(response)
                    
                case .undocumented(statusCode: let code, let payload):
                    VULogger.log(tag: .error, "Undocumented", code, payload)
            }
        }
    }
    
    
    private func validate() -> Result<Void, ValidationError> {
        guard viewModel.logType != .select else {
            return .failure(.MISSING_UPDATE_TYPE)
        }
        
        guard !viewModel.news.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return .failure(.UNTYPED_WORK_DESC)
        }
        
        guard viewModel.selectedFiles.count > 0 else {
            return .failure(.NO_DOCUMENTS)
        }
        
        guard viewModel.selectedFiles.filter({ (inferFileSize(from: $0) ?? 0) > 10_000_000 }).isEmpty else { 
            return .failure(.FILE_TOO_LARGE)
        }
        
        return .success(())
    }
    
}



extension CrewNewWorkLogInteractor {
    
    
    private func talkBackToParentAfterAssemblingLogResponse(_ response: Components.Responses.newly_hyphen_made_hyphen_ticket_hyphen_log.Body.jsonPayload) {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(response.data)
            let decodedData = try decode(encodedData, to: FPTicketLog.self).get()
            listener?.didAdd(log: decodedData)
            
        } catch {
            VULogger.log(tag: .error, error)
        }
    }
    
}



/// Conformance to the ``CrewNewWorkLogPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``CrewNewWorkLogViewController``.
extension CrewNewWorkLogInteractor: CrewNewWorkLogPresentableListener {
    func didGetDismissed() {
        listener?.didDismissCrewNewWorkLog()
    }
}
