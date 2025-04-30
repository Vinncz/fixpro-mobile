import RIBs
import UniformTypeIdentifiers
import VinUtility
import RxSwift



/// Contract adhered to by ``NewTicketRouter``, listing the attributes and/or actions 
/// that ``NewTicketInteractor`` is allowed to access or invoke.
protocol NewTicketRouting: ViewableRouting {
    func dismiss()
}



/// Contract adhered to by ``NewTicketViewController``, listing the attributes and/or actions
/// that ``NewTicketInteractor`` is allowed to access or invoke.
protocol NewTicketPresentable: Presentable {
    
    
    /// Reference to ``NewTicketInteractor``.
    var presentableListener: NewTicketPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: NewTicketSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `NewTicketRIB`'s parent, listing the attributes and/or actions
/// that ``NewTicketInteractor`` is allowed to access or invoke.
protocol NewTicketListener: AnyObject {
    func didRaise(ticket: FPLightweightIssueTicket)
}



/// The functionality centre of `NewTicketRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class NewTicketInteractor: PresentableInteractor<NewTicketPresentable>, NewTicketInteractable {
    
    
    /// Reference to ``NewTicketRouter``.
    weak var router: NewTicketRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: NewTicketListener?
    
    
    /// Reference to the component of this RIB.
    var component: NewTicketComponent
    
    
    /// Bridge to the ``NewTicketSwiftUIVIew``.
    private var viewModel = NewTicketSwiftUIViewModel()
    
    
    /// Constructs an instance of ``NewTicketInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: NewTicketComponent) {
        self.component = component
        let presenter = component.newTicketViewController
        
        super.init(presenter: presenter)
        
        presenter.presentableListener = self
    }
    
    
    /// Customization point that is invoked after self becomes active.
    override func didBecomeActive() {
        super.didBecomeActive()
        configureViewModel()
        VULogger.log("didBecomeActive")
    }
    
    
    /// Customization point that is invoked before self is fully detached.
    override func willResignActive() {
        super.willResignActive()
    }
    
    
    /// Configures the view model.
    private func configureViewModel() {
        viewModel.didIntendToSubmit = { [weak self] in
            self?.submit()
        }
        
        presenter.bind(viewModel: self.viewModel)
    }
    
}



extension NewTicketInteractor {
    
    
    enum ValidationError: String, Error {
        case PLACEHOLDER_NOT_FILLED = "Do select the appropriate issue type."
        case INCOMPLETE_ANSWER = "All fields are required."
        case NO_DOCUMENTS = "No documents were attached. Select some first."
        case FILE_TOO_LARGE = "One or more files are above the 5MB limit."
    }
    
    
    private func submit() {
        if case .failure(let error) = validate() { 
            viewModel.errorLabel = error.rawValue
            return 
        }
        
        var continueOn = true
        VUPresentLoadingAlert(
            on: router?.viewControllable.uiviewController,
            title: "Submitting your application..", 
            message: "Once approved, you can start using FixPro. Your progress is saved in case you cancel this submission.", 
            cancelButtonCTA: "Cancel", 
            delay: 20, 
            cancelAction: {
                continueOn = false
            }
        )
        
        component.locationBeacon.locate { locationRetrievalResult in
            switch locationRetrievalResult {
                case .success(let location):
                    VULogger.log("Located self")
                    
                    if !continueOn {
                        VULogger.log("Cancelled network request")
                        return
                    }
                    
                    Task { [weak self] in
                        guard let self else { return }
                        
                        do {
                            let attemptedSubmission = try await component.networkingClient.gateway.raiseTicket(.init(
                                headers: .init(accept: [.init(contentType: .json)]),
                                body: .json(.init(
                                    issue_type: .init(rawValue: viewModel.issueType.rawValue)!,
                                    response_level: .init(rawValue: viewModel.suggestedResponseLevel.rawValue)!, 
                                    stated_issue: viewModel.statedIssue, 
                                    location: .init(
                                        stated_location: viewModel.statedLocation,
                                        gps_location: .init(
                                            latitude: location.latitude,
                                            longitude: location.longitude
                                        )
                                    ),
                                    supportive_documents: viewModel.selectedFiles.map { file in .init(
                                        resource_type: .init(rawValue: UTType(file.pathExtension)?.identifier ?? UTType.data.identifier),
                                        resource_name: file.lastPathComponent,
                                        resource_size: Double(inferFileSize(from: file) ?? 0), 
                                        resource_content: fileToBase64(on: file)
                                    )}
                                ))
                            ))
                            
                            switch attemptedSubmission {
                            case .created(let made):
                                VULogger.log(tag: .network, "Did submit a new ticket")
                                viewModel.reset()
                                    
                                DispatchQueue.main.sync {
                                    self.router?.dismiss()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        self.router?.dismiss()
                                    }
                                }
                                 
                                let response = try made.body.json
                                self.talkBackToParentAfterAssemblingTicketResponse(response)
                                    
                            case .badRequest(let errorResponse):
                                VULogger.log(tag: .error, errorResponse)
                                    
                            case .undocumented(statusCode: let code, let payload):
                                VULogger.log(tag: .error, "\(code) -- \(payload)")
                            }
                            
                        } catch {
                            VULogger.log(tag: .error, error)
                        }
                    }
                    
                case .failure(let error):
                    VULogger.log(tag: .error, error)
            }
        }
        
    }
    
    
    private func validate() -> Result<Void, ValidationError> {
        guard viewModel.issueType != .select else {
            return .failure(.PLACEHOLDER_NOT_FILLED)
        }
        
        guard !viewModel.statedLocation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, 
              !viewModel.statedIssue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty 
        else {
            return .failure(.INCOMPLETE_ANSWER)
        }
        
        guard viewModel.selectedFiles.count > 0 else {
            return .failure(.NO_DOCUMENTS)
        }
        
        guard viewModel.selectedFiles.filter({ (inferFileSize(from: $0) ?? 0) > 5_000_000 }).isEmpty else { 
            return .failure(.FILE_TOO_LARGE)
        }
        
        return .success(())
    }
    
}



extension NewTicketInteractor {
    
    
    private func talkBackToParentAfterAssemblingTicketResponse(_ response: Components.Schemas.inline_response_201) {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(response.data)
            let decodedData = try decode(encodedData, to: FPLightweightIssueTicketDTO.self).get()
            listener?.didRaise(ticket: decodedData.toDomainModel())
            
        } catch {
            VULogger.log(tag: .error, error)
        }
    }
    
}



/// Conformance to the ``NewTicketPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``NewTicketViewController``.
extension NewTicketInteractor: NewTicketPresentableListener {}
