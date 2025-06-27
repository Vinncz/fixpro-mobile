import RIBs
import RxSwift
import VinUtility



/// Contract adhered to by ``OperationsRouter``, listing the attributes and/or actions 
/// that ``OperationsInteractor`` is allowed to access or invoke.
protocol OperationsRouting: ViewableRouting {
    
    
    /// Attaches the RoleAppropriation RIB.
    func routeToRoleAppropriation(fromNotification: FPNotificationDigest?)
    
    
    /// Removes the view hierarchy from any `ViewControllable` instances this RIB may have added.
    func cleanupViews()
    
    
    /// Removes the hosting controller (swiftui embed) from the view hierarchy and deallocates it.
    func removeSwiftUI()
    
}



/// Contract adhered to by ``OperationsViewController``, listing the attributes and/or actions
/// that ``OperationsInteractor`` is allowed to access or invoke.
protocol OperationsPresentable: Presentable {
    
    
    /// Reference to ``OperationsInteractor``.
    var presentableListener: OperationsPresentableListener? { get set }
    
    
    /// Reference to the view model.
    var viewModel: OperationsSwiftUIViewModel? { get }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: OperationsSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `OperationsRIB`'s parent, listing the attributes and/or actions
/// that ``OperationsInteractor`` is allowed to access or invoke.
protocol OperationsListener: AnyObject {
    func didIntendLogOut()
}



/// The functionality centre of `OperationsRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class OperationsInteractor: PresentableInteractor<OperationsPresentable>, OperationsInteractable {
    
    
    /// Reference to ``OperationsRouter``.
    weak var router: OperationsRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: OperationsListener?
    
    
    /// Reference to the component of this RIB.
    var component: OperationsComponent
    
    
    /// Bridge to the ``OperationsSwiftUIVIew``.
    private var viewModel = OperationsSwiftUIViewModel()
    
    
    /// Others.
    var triggerNotification: FPNotificationDigest?
    
    
    /// Constructs an instance of ``OperationsInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: OperationsComponent, presenter: OperationsPresentable, triggerNotification: FPNotificationDigest?) {
        self.component = component
        self.triggerNotification = triggerNotification
        
        super.init(presenter: presenter)
        
        presenter.presentableListener = self
    }
    
    
    /// Customization point that is invoked after self becomes active.
    override func didBecomeActive() {
        super.didBecomeActive()
        configureViewModel()
        
        performLaunchBootstrapping()
    }
    
    
    /// Customization point that is invoked before self is fully detached.
    override func willResignActive() {
        super.willResignActive()
        presenter.unbindViewModel()
        router?.cleanupViews()
        router?.removeSwiftUI()
    }
    
    
    deinit {
        VULogger.log("Deinitialized.")
    }
    
    
    /// Configures the view model.
    private func configureViewModel() {
        viewModel.didIntendToLogOut = { [weak self] in
            self?.didIntendToLogOut()
        }
        
        presenter.bind(viewModel: self.viewModel)
    }
    
    
    fileprivate func performLaunchBootstrapping() {
        Task { [weak self] in
            guard let self else { return }
            
            self.viewModel.state = .normal("Establishing connection with Area..")
            
            let accessTokenExpiryDate = await self.component.sessionIdentityService.accessTokenExpirationDate!
            if accessTokenExpiryDate < .now.addingTimeInterval(1800) {
                do {
                    try await self.component.sessionidentityServiceUpkeeper.renew()
                    
                } catch let error as FPError {
                    switch error {
                    case .INVALID_TOKEN:
                        self.viewModel.state = .failure("Cannot establish a connection with the Area. This can happen either through a network issue or they are down for maintenance.", "Try again") { [weak self] in
                            self?.performLaunchBootstrapping()
                        }
                        
                    case .EXPIRED_REFRESH_TOKEN:
                        self.viewModel.state = .failure("Session has expired.", "Back to pairing") { [weak self] in
                            self?.didIntendToLogOut()
                        }
                        
                    default: 
                        self.viewModel.state = .failure("\(error.errorDescription ?? "") \(error.recoverySuggestion ?? "")", "Try again") { [weak self] in
                            self?.performLaunchBootstrapping()
                        }
                    }
                    
                    return
                }
            }
            
            router?.routeToRoleAppropriation(fromNotification: triggerNotification)
        }
    }
    
}



extension OperationsInteractor {
    
    
    /// Informs `RootRIB` to detach self and remove any traces of pairing.
    func didIntendToLogOut() {
        component.keychainStorageServicing.remove(for: .KEYCHAIN_KEY_FOR_FPONBOARDINGSERVICE_MEMENTO_SNAPSHOT)
        component.keychainStorageServicing.remove(for: .KEYCHAIN_KEY_FOR_NETWORKING_CLIENT_MEMENTO_SNAPSHOT)
        component.keychainStorageServicing.remove(for: .KEYCHAIN_KEY_FOR_FPSESSION_IDENTITY_MEMENTO_SNAPSHOT)
        
        presenter.unbindViewModel()
        
        router?.cleanupViews()
        router?.removeSwiftUI()
        
        listener?.didIntendLogOut()
    }
    
}



/// Conformance to the ``OperationsPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``OperationsViewController``.
extension OperationsInteractor: OperationsPresentableListener {}
