import Foundation
import RIBs
import RxSwift
import VinUtility



/// Contract adhered to by ``CrewDelegatingRouter``, listing the attributes and/or actions 
/// that ``CrewDelegatingInteractor`` is allowed to access or invoke.
protocol CrewDelegatingRouting: ViewableRouting {}



/// Contract adhered to by ``CrewDelegatingViewController``, listing the attributes and/or actions
/// that ``CrewDelegatingInteractor`` is allowed to access or invoke.
protocol CrewDelegatingPresentable: Presentable {
    
    
    /// Reference to ``CrewDelegatingInteractor``.
    var presentableListener: CrewDelegatingPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: CrewDelegatingSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `CrewDelegatingRIB`'s parent, listing the attributes and/or actions
/// that ``CrewDelegatingInteractor`` is allowed to access or invoke.
protocol CrewDelegatingListener: AnyObject {
    func didDismissCrewDelegating()
}



/// The functionality centre of `CrewDelegatingRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class CrewDelegatingInteractor: PresentableInteractor<CrewDelegatingPresentable>, CrewDelegatingInteractable {
    
    
    /// Reference to ``CrewDelegatingRouter``.
    weak var router: CrewDelegatingRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: CrewDelegatingListener?
    
    
    /// Reference to the component of this RIB.
    var component: CrewDelegatingComponent
    
    
    /// Bridge to the ``CrewDelegatingSwiftUIVIew``.
    private var viewModel = CrewDelegatingSwiftUIViewModel()
    
    
    var ticketId: String
    var issueType: FPIssueType
    
    
    /// Constructs an instance of ``CrewDelegatingInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: CrewDelegatingComponent, ticketId: String, issueType: FPIssueType) {
        self.component = component
        self.ticketId = ticketId
        self.issueType = issueType
        
        let presenter = component.crewDelegatingViewController
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
        Task { 
            let personnels = await retrieveMatchingPersonnels()
            
            Task { @MainActor in
                viewModel.availablePersonnel = personnels.filter { $0.speciality.contains(issueType) }
            }
        }
        
        viewModel.didIntendToDismiss = { [weak self] in
            self?.didGetDismissed()
        }
        viewModel.didIntendToDelegate = { [weak self] in 
            self?.delegateToSelectedPersonnel()
        }
        presenter.bind(viewModel: self.viewModel)
    }
    
}



extension CrewDelegatingInteractor {
    
    
    func delegateToSelectedPersonnel() {
        guard viewModel.selectedPersonnel.count > 0 else {
            viewModel.validationLabel = "Do select somebody to delegate this ticket to."
            return
        }
        
        guard !viewModel.executiveSummary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            viewModel.validationLabel = "Do fill out the executive summary."
            return
        }
        
        let selectedPersonnel = viewModel.selectedPersonnel
        Task {
            do {
                try await commitToDelegatingPersonnel(selectedPersonnel.map{ $0 }).get()
                Task { @MainActor in
                    listener?.didDismissCrewDelegating()
                }
                
            } catch {
                viewModel.validationLabel = error.localizedDescription
            }
        }
    }
    
    
    func commitToDelegatingPersonnel(_ personnels: [FPPerson]) async -> Result<Void, FPError> {
        do {
            let attemptedRequest = try await component.networkingClient.gateway.delegateIssueTicket(.init(
                path: .init(ticket_id: ticketId),
                headers: .init(accept: [.init(contentType: .json)]),
                body: .json(.init(
                    target_member_id: personnels.map { $0.id },
                    executive_summary: viewModel.executiveSummary
                ))
            ))
            
            switch attemptedRequest {
                case .created:
                    return .success(())
                    
                case .undocumented(statusCode: let code, let payload):
                    VULogger.log(tag: .error, code, payload)
                    return .failure(.UNEXPECTED_RESPONSE)
            }
            
        } catch {
            VULogger.log(tag: .error, error)
            return .failure(.UNREACHABLE)
            
        }
    }
    
        
    func retrieveMatchingPersonnels() async -> [FPPerson] {
        do {
            let attemptedRequest = try await component.networkingClient.gateway.getAreaMembers(.init(headers: .init(accept: [.init(contentType: .json)])))
            
            switch attemptedRequest {
                case .ok(let response):
                    let encoder = JSONEncoder()
                    let encodedResponse = try encoder.encode(response.body.json.data)
                    let decodedResponse = try decode(encodedResponse, to: [FPPerson].self).get()
                    
                    return decodedResponse
                    
                case .forbidden:
                    VULogger.log(tag: .error, "Forbidden")
                    
                case .undocumented(statusCode: let code, let payload):
                    VULogger.log(tag: .error, code, payload)
            }
            
            return []
            
        } catch {
            VULogger.log(tag: .error, error)
            return []
            
        }
    }
    
}



/// Conformance to the ``CrewDelegatingPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``CrewDelegatingViewController``.
extension CrewDelegatingInteractor: CrewDelegatingPresentableListener {
    func didGetDismissed() {
        listener?.didDismissCrewDelegating()
    }
}
