import Foundation
import RIBs
import RxSwift
import VinUtility



/// Contract adhered to by ``InboxRouter``, listing the attributes and/or actions 
/// that ``InboxInteractor`` is allowed to access or invoke.
protocol InboxRouting: ViewableRouting {}



/// Contract adhered to by ``InboxViewController``, listing the attributes and/or actions
/// that ``InboxInteractor`` is allowed to access or invoke.
protocol InboxPresentable: Presentable {
    
    
    /// Reference to ``InboxInteractor``.
    var presentableListener: InboxPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: InboxSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `InboxRIB`'s parent, listing the attributes and/or actions
/// that ``InboxInteractor`` is allowed to access or invoke.
protocol InboxListener: AnyObject {
    func didTap(notification: FPNotificationDigest)
}



/// The functionality centre of `InboxRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class InboxInteractor: PresentableInteractor<InboxPresentable>, InboxInteractable {
    
    
    /// Reference to ``InboxRouter``.
    weak var router: InboxRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: InboxListener?
    
    
    /// Reference to the component of this RIB.
    var component: InboxComponent
    
    
    /// Bridge to the ``InboxSwiftUIVIew``.
    private var viewModel = InboxSwiftUIViewModel()
    
    
    /// Constructs an instance of ``InboxInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: InboxComponent, presenter: InboxViewController) {
        self.component = component
        
        super.init(presenter: presenter)
        
        presenter.presentableListener = self
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
    
    
    deinit {
        VULogger.log("Deinitialized.")
    }
    
    
    /// Configures the view model.
    private func configureViewModel() {
        Task {
            viewModel.notifications = await fetchNotifications()
        }
        
        viewModel.didIntendToRefreshMailbox = { [weak self] in
            if let notifs = await self?.fetchNotifications() {
                self?.viewModel.notifications = notifs
            }
        }
        
        viewModel.didTapNotification = { [weak self] notification in
            self?.listener?.didTap(notification: notification)
        }
        
        presenter.bind(viewModel: self.viewModel)
    }
    
}



fileprivate extension InboxInteractor {
    
    
    func fetchNotifications() async -> [FPNotificationDigest] {
        var notifs: [FPNotificationDigest] = []
        
        switch try? await component.networkingClient.gateway.getInbox(.init(
            headers: .init(accept: [.init(contentType: .json)])
        )) {
            case .ok(let unparsedResponse):
                switch unparsedResponse.body {
                    case .json(let jsonBody):
                        let receivedNotifications = jsonBody.data
                        _ = receivedNotifications.map { notifications in
                            notifications.map { notification in
                                guard 
                                    let title = notification.title, 
                                    let body = notification.body, 
                                    let sentOn = notification.sent_on,
                                    let actionable = notification.actionable,
                                    let actionableGenus = FPRemoteNotificationActionable.Genus(rawValue: "\(actionable.genus?.value ?? "")"),
                                    let actionableSpecies = FPRemoteNotificationActionable.Species(rawValue: "\(actionable.species?.value ?? "")")
                                else { return }
                                
                                notifs.append(
                                    FPNotificationDigest(
                                        id: UUID().uuidString, 
                                        title: title, 
                                        body: body, 
                                        sentOn: sentOn,
                                        actionable: FPRemoteNotificationActionable(
                                            genus: actionableGenus, 
                                            species: actionableSpecies,
                                            destination: actionable.segue_destination
                                        )
                                    )
                                )
                            }
                        }
                }
                
            case .undocumented(statusCode: let code, let payload):
                VULogger.log(tag: .network, "Unexpected response. \(code) - \(payload)")
                
            case .none:
                break
        }
        
        return notifs
    }
    
}



/// Conformance to the ``InboxPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``InboxViewController``.
extension InboxInteractor: InboxPresentableListener {}
