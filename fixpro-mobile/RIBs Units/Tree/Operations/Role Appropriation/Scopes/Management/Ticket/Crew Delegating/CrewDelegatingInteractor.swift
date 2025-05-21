import Foundation
import RIBs
import RxSwift
import VinUtility



/// Contract adhered to by ``CrewDelegatingRouter``, listing the attributes and/or actions 
/// that ``CrewDelegatingInteractor`` is allowed to access or invoke.
protocol CrewDelegatingRouting: ViewableRouting {
    func dismiss()
}



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
    func didAdd(handlers: [FPPerson])
    func didAdd(log: FPTicketLog)
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
    
    
    var ticket: FPTicketDetail
    
    
    /// Constructs an instance of ``CrewDelegatingInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: CrewDelegatingComponent, ticket: FPTicketDetail) {
        self.component = component
        self.ticket = ticket
        
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
                viewModel.selectedPersonnel = personnels.filter { ticket.handlers.map{$0.model.name}.contains($0.name) }
                viewModel.availablePersonnel = personnels.filter { $0.specialties.contains(ticket.issueTypes) }
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
                Task { @MainActor in
                    VUPresentLoadingAlert(
                        on: router?.viewControllable.uiviewController,
                        title: "Submitting your contribution", 
                        message: "This shouldn't take more than a minute. Should you cancel this submission, your progress is saved.", 
                        cancelButtonCTA: "Cancel", 
                        delay: 30, 
                        cancelAction: {}
                    )
                }
                
                try await commitToDelegatingPersonnel(selectedPersonnel.map{ $0 }).get()
                listener?.didAdd(handlers: selectedPersonnel)
                
                DispatchQueue.main.sync {
                    self.router?.dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.router?.dismiss()
                    }
                }
                
            } catch {
                viewModel.validationLabel = error.localizedDescription
            }
        }
    }
    
    
    func commitToDelegatingPersonnel(_ personnels: [FPPerson]) async -> Result<Void, FPError> {
        do {
            let attemptedRequest = try await component.networkingClient.gateway.postTicketHandlers(.init(
                path: .init(ticket_id: ticket.id),
                headers: .init(accept: [.init(contentType: .json)]),
                body: .json(.init(
                    appointed_member_ids: [], 
                    work_description: "", 
                    issue_types: ""
                ))
            ))
            
            switch attemptedRequest {
            case .ok(let made):
                let response = try made.body.json
                let encoder = JSONEncoder()
                let encodedData = try encoder.encode(response.data)
                let decodedData = try decode(encodedData, to: FPTicketLog.self).get()
                listener?.didAdd(log: decodedData)
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
