import Foundation
import RIBs
import RxSwift
import VinUtility



/// Contract adhered to by ``TicketListsRouter``, listing the attributes and/or actions 
/// that ``TicketListsInteractor`` is allowed to access or invoke.
protocol TicketListsRouting: ViewableRouting {}



/// Contract adhered to by ``TicketListsViewController``, listing the attributes and/or actions
/// that ``TicketListsInteractor`` is allowed to access or invoke.
protocol TicketListsPresentable: Presentable {
    
    
    /// Reference to ``TicketListsInteractor``.
    var presentableListener: TicketListsPresentableListener? { get set }
    
    
    /// Reference to the view model.
    var viewModel: TicketListsSwiftUIViewModel? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: TicketListsSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `TicketListsRIB`'s parent, listing the attributes and/or actions
/// that ``TicketListsInteractor`` is allowed to access or invoke.
protocol TicketListsListener: AnyObject {
    func navigateToTicketDetail(forId ticketId: String)
}



/// The functionality centre of `TicketListsRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class TicketListsInteractor: PresentableInteractor<TicketListsPresentable>, TicketListsInteractable {
    
    
    /// Reference to ``TicketListsRouter``.
    weak var router: TicketListsRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: TicketListsListener?
    
    
    /// Reference to the component of this RIB.
    var component: TicketListsComponent
    
    
    /// Constructs an instance of ``TicketListsInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: TicketListsComponent) {
        self.component = component
        let presenter = component.ticketListsViewController
        
        super.init(presenter: presenter)
        
        presenter.presentableListener = self
    }
    
    
    /// Customization point that is invoked after self becomes active.
    override func didBecomeActive() {
        super.didBecomeActive()
        configureViewModel()
        Task { @MainActor in
            presenter.viewModel?.tickets = try await self.fetchTicketList().get()
        }
    }
    
    
    /// Customization point that is invoked before self is fully detached.
    override func willResignActive() {
        super.willResignActive()
    }
    
    
    deinit {
        VULogger.log("Deinitialized.")
    }
    
    
    /// Configures the view model.
    private func configureViewModel() {
        let viewModel = TicketListsSwiftUIViewModel(
            roleContext: component.authorizationContext, 
            tickets: [/* TODO: fetch from cache */], 
            didIntendToRefreshTicketList: {}, 
            didTapTicket: { [weak self] ticket in
                self?.listener?.navigateToTicketDetail(forId: ticket.id)
            }
        )
        
        viewModel.didIntendToRefreshTicketList = { [weak self] in 
            guard let self else { return }
            if let tickets = try? await self.fetchTicketList().get() {
                viewModel.tickets = tickets
            }
        }
        
        presenter.bind(viewModel: viewModel)
    }
    
}



extension TicketListsInteractor {
    
    
    func fetchTicketList() async -> Result<[FPLightweightIssueTicket], FPError> {
        do {
            let attemptedRequest = try await component.networkingClient.gateway.getTickets(.init(headers: .init(accept: [.init(contentType: .json)])))
            
            switch attemptedRequest {
                case .ok(let response): 
                    let encoder = JSONEncoder()
                    let decoder = JSONDecoder()   
                    let encodedResponse = try encoder.encode(response.body.json.data)
                    let decodedResponse = try decoder.decode([FPLightweightIssueTicketDTO].self, from: encodedResponse)
                    
                    return .success(decodedResponse.map { $0.toDomainModel() })
                    
                case .undocumented(statusCode: let code, let payload):
                    VULogger.log(tag: .error, "\(code) -- \(payload)")
                    return .failure(.UNEXPECTED_RESPONSE)
            }
            
        } catch {
            VULogger.log(tag: .error, error)
            return .failure(.UNREACHABLE)
            
        }
    }
    
    
    func didMake(ticket: FPLightweightIssueTicket) {
        presenter.viewModel?.tickets.append(ticket)
        VULogger.log("Did append the new ticket to the viewmodel")
    }
    
    
    func refreshList() {
        Task { @MainActor in
            presenter.viewModel?.tickets = try await self.fetchTicketList().get()
        }
    }
    
}



/// Conformance to the ``TicketListsPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``TicketListsViewController``.
extension TicketListsInteractor: TicketListsPresentableListener {}
