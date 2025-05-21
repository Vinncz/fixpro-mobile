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
        Task {
            do {
                let attemptedRequest = try await component.networkingClient.gateway.getIssueTypes(.init(headers: .init(accept: [.init(contentType: .json)])))
                switch attemptedRequest {
                    case .ok(let response):
                        let jsonBody = try response.body.json.data
                        let issueTypes: [FPIssueType?] = jsonBody!.compactMap({ element in
                            guard
                                let id = element.id,
                                let name = element.name,
                                let serviceLevelAgreementDurationHour = element.service_level_agreement_duration_hour
                            else { return nil }
                            
                            return FPIssueType(id: id, name: name, serviceLevelAgreementDurationHour: Int(serviceLevelAgreementDurationHour))
                        })
                        viewModel.issueTypes = issueTypes.compactMap{ $0 }
                        
                    case .undocumented(statusCode: let code, let payload):
                        VULogger.log(tag: .error, code, payload)
                }
            } catch {
                
            }
        }
        
        viewModel.didIntendToSubmit = { [weak self] in
            self?.submit()
        }
        
        presenter.bind(viewModel: self.viewModel)
    }
    
}



extension NewTicketInteractor {
    
    
    enum ValidationError: String, Error {
        case PLACEHOLDER_NOT_FILLED = "Select at least one category that closely matches the prolem you encounter."
        case INCOMPLETE_ANSWER = "Issue description or location may be empty."
        case NO_DOCUMENTS = "No documents were attached. At least one is expected."
        case FILE_TOO_LARGE = "One or more documents are above the 5MB limit."
        case SUMMARY_TOO_LONG = "Summary should not be above 127 characters."
    }
    
    
    private func submit() {
        if case .failure(let error) = validate() { 
            viewModel.errorLabel = error.rawValue
            return 
        }
        
        var continueOn = true
        VUPresentLoadingAlert(
            on: router?.viewControllable.uiviewController,
            title: "Hang tight while we process your request.", 
            message: "We are taking GPS position to mark where the issue occured. This should take less than 30 seconds. Your answer is be saved should you cancel.", 
            cancelButtonCTA: "Cancel", 
            delay: 30, 
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
                        let attemptedSubmission = try await component.networkingClient.gateway.postTicket(.init(
                            headers: .init(accept: [.init(contentType: .json)]),
                            body: .json(.init(data: .init(
                                issue_type_ids: viewModel.selectedIssueTypes.map { $0.id }, 
                                response_level: .init(stringLiteral: viewModel.suggestedResponseLevel.rawValue), 
                                executive_summary: viewModel.executiveSummary,
                                stated_issue: viewModel.statedIssue, 
                                location: .init(
                                    stated_location: viewModel.statedLocation,
                                    gps_location: .init(
                                        latitude: location.latitude,
                                        longitude: location.longitude
                                    )
                                ), 
                                supportive_documents: viewModel.selectedFiles.map {
                                    .init(
                                        resource_type: VUInferMimeType(for: $0), 
                                        resource_name: $0.lastPathComponent, 
                                        resource_size: Double(inferFileSize(from: $0) ?? 0), 
                                        resource_content: fileToBase64(on: $0)
                                    )
                                }
                            )))
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
        guard viewModel.selectedIssueTypes.count > 0 else {
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
        
        guard viewModel.executiveSummary.count <= 127 else {
            return .failure(.SUMMARY_TOO_LONG)
        }
        
        return .success(())
    }
    
}



extension NewTicketInteractor {
    
    
    private func talkBackToParentAfterAssemblingTicketResponse(_ response: Components.Responses.newly_hyphen_made_hyphen_ticket.Body.jsonPayload) {
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
