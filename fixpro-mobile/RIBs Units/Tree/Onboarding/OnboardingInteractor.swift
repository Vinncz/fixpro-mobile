import Foundation
import RIBs
import RxSwift
import VinUtility



/// Contract adhered to by ``OnboardingRouter``, listing the attributes and/or actions 
/// that ``OnboardingInteractor`` is allowed to access or invoke.
protocol OnboardingRouting: ViewableRouting {
    func pairingFlow()
    func exitFlow()
}



/// Contract adhered to by ``OnboardingViewController``, listing the attributes and/or actions
/// that ``OnboardingInteractor`` is allowed to access or invoke.
protocol OnboardingPresentable: Presentable {
    
    
    /// Reference to ``OnboardingInteractor``.
    var presentableListener: OnboardingPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: OnboardingSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `OnboardingRIB`'s parent, listing the attributes and/or actions
/// that ``OnboardingInteractor`` is allowed to access or invoke.
protocol OnboardingListener: AnyObject {
    func didFinishPairing()
}



/// The functionality centre of `OnboardingRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class OnboardingInteractor: PresentableInteractor<OnboardingPresentable>, OnboardingInteractable {
    
    
    /// Reference to ``OnboardingRouter``.
    weak var router: OnboardingRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: OnboardingListener?
    
    
    /// Reference to the component of this RIB.
    var component: OnboardingComponent
    
    
    /// Bridge to the ``OnboardingSwiftUIVIew``.
    private var viewModel = OnboardingSwiftUIViewModel()
    
    
    /// Constructs an instance of ``OnboardingInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: OnboardingComponent) {
        self.component = component
        let presenter = component.onboardingViewController
        
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
    
    
    /// Configures the view model. Invoked only once, upon the activation of this interactor.
    private func configureViewModel() {
        if let encodedOnboardingServiceSnapshot = try? component.keychainStorageServicing.retrieve(for: .KEYCHAIN_KEY_FOR_FPONBOARDINGSERVICE_MEMENTO_SNAPSHOT, limit: 1).get(),
           let onboardingSnapshot = try? decode(Data(base64Encoded: encodedOnboardingServiceSnapshot)!, to: FPOnboardingServiceSnapshot.self).get(),
           let encodedNetworkingClientSnapshot = try? component.keychainStorageServicing.retrieve(for: .KEYCHAIN_KEY_FOR_NETWORKING_CLIENT_MEMENTO_SNAPSHOT, limit: 1).get(),
           let networkingClientSnapshot = try? decode(Data(base64Encoded: encodedNetworkingClientSnapshot)!, to: FPNetworkingClientSnapshot.self).get()
        {
            // Scenario 1 -- One has outbound application.
            
            let onboardingService = FPOnboardingService.boot(fromSnapshot: onboardingSnapshot).get()
            component.onboardingServiceProxy.back(with: onboardingService)
            
            let onboardingServiceMementoAgent = FPMementoAgent<FPOnboardingService, FPOnboardingServiceSnapshot>(storage: component.keychainStorageServicing, target: onboardingService, storageKey: .KEYCHAIN_KEY_FOR_FPONBOARDINGSERVICE_MEMENTO_SNAPSHOT)
            component.onboardingServiceMementoAgentProxy.back(with: onboardingServiceMementoAgent)
            
            let networkingClient = FPNetworkingClient.boot(fromSnapshot: networkingClientSnapshot).get()
            component.networkingClientProxy.back(with: networkingClient)
            
            onboardingService.networkingClient = networkingClient
            
            configureViewModelForOngoingPendingApplication()
            
        } else {
            // Scenario 2 -- One does not have outbound application.
            VULogger.log("No snapshot present. Assuming self has no outbound application.")
            
        }
        
        viewModel.quePairingFlow = { [weak self] in
            self?.router?.pairingFlow()
        }
        
        presenter.bind(viewModel: self.viewModel)
    }
    
}



extension OnboardingInteractor {
    
    
    func configureViewModelForOngoingPendingApplication() {
        guard let onboardingService = component.onboardingServiceProxy.backing, 
              let networkingClient = component.networkingClientProxy.backing
        else {
            fatalError("Should not invoke this method when onboardingservice is absent.")
        }
        
        viewModel.applicationReceipt = .init(areaName: onboardingService.areaName, 
                                             appliedOnDate: onboardingService.applicationSubmissionDate!, 
                                             offerExpiryDate: onboardingService.applicationIdExpiryDate!)
        VULogger.log("Added ApplicationReceipt")
        
        viewModel.applicationState = .undecided
        
        viewModel.refreshApplicationStatus = { [weak self] in 
            
            // Block refresh attempt if self has already exchanged code for tokens 
            // or has received an application-rejection notice.
            guard 
                self?.viewModel.applicationState != .approvedAndReadyForTransition 
             && self?.viewModel.applicationState != .rejected 
            else { return }
            
            Task {
                switch await onboardingService.checkApplicationStatus() {
                    
                    // Condition 1 -- Self application has been approved, and is now getting an authenticationCode to start
                    //                communicating with the backend more.
                    case .success(let authenticationCode):
                        guard let self else { return }
                        VULogger.log("Application approved")
                        
                        switch await FPSessionIdentityService.exhangeForTokens(authenticationCode: authenticationCode, networkingClient: networkingClient) {
                            
                            // Subcondition 1 -- Successful exchange. Only invoked once.
                            case .success(let sessionIdentityService):
                                VULogger.log("Successful token exchange")
                                
                                // <Prep for flow change>
                                self.component.sessionIdentityServiceProxy.back(with: sessionIdentityService)
                                
                                let sessionIdentityServiceMementoAgent = FPMementoAgent<FPSessionIdentityService, FPSessionIdentityServiceSnapshot>(storage: self.component.keychainStorageServicing, 
                                                                                                                                                    target: sessionIdentityService as! FPSessionIdentityService, 
                                                                                                                                                    storageKey: .KEYCHAIN_KEY_FOR_FPSESSION_IDENTITY_MEMENTO_SNAPSHOT)
                                self.component.sessionIdentityServiceMementoAgentProxy.back(with: sessionIdentityServiceMementoAgent)
                                
                                let sessionIdentityServiceUpkeeper = FPSessionIdentityUpkeeper(storage: sessionIdentityService, networkingClient: networkingClient)
                                self.component.sessionIdentityUpkeeperProxy.back(with: sessionIdentityServiceUpkeeper)
                                
                                self.component.networkingClientProxy.back(with: networkingClient)
                                
                                Task {
                                    await sessionIdentityServiceMementoAgent.snap()
                                }
                                // </Prep for flow change>
                                
                                
                                // Show the button that transitions to operations flow once tapped.
                                // When the button is shown, not tapped, and the app is restarted, the flow switches regardless.
                                self.viewModel.applicationState = .approvedAndReadyForTransition
                                
                                
                            // Subcondition 2 -- Failed exchange.
                            case .failure(let error):
                                switch error {
                                        
                                    // Subsubcondition 1 -- Code was exchanged while self didn't receive any tokens.
                                    //                      No helping this one.
                                    case .CODE_ALREADY_EXCHANGED:
                                        VULogger.log("ApplicationId has already been exchanged with tokens")
                                        
                                        self.component.onboardingServiceProxy.backing?.cancelApplication()
                                        self.viewModel.applicationReceipt = nil
                                        self.viewModel.applicationState = .undecided
                                        self.component.keychainStorageServicing.remove(for: .KEYCHAIN_KEY_FOR_FPONBOARDINGSERVICE_MEMENTO_SNAPSHOT)
                                        self.component.keychainStorageServicing.remove(for: .KEYCHAIN_KEY_FOR_NETWORKING_CLIENT_MEMENTO_SNAPSHOT)
                                        self.component.keychainStorageServicing.remove(for: .KEYCHAIN_KEY_FOR_FPSESSION_IDENTITY_MEMENTO_SNAPSHOT)
                                    
                                    // Subsubcondition 2 -- Other failure.
                                    default:
                                        VULogger.log(tag: .error, "Token exchange failure: \(error)")
                                        break
                                }
                                
                                
                        }
                        
                        
                    // Condition 2 -- Self application has not been approved, more waiting awaits.
                    case .failure(let error):
                        guard let self else { return }
                        
                        VULogger.log("Application status check failure: \(error)")
                        
                        switch error {
                                
                            // Subcondition 1 -- Hasn't been approved or is supplying an invalid `applicationId`.
                            case .UNDECIDED_APPLICATION:
                                self.viewModel.applicationState = .undecided
                                
                            // Subcondition 2 -- Rejected.
                            case .REJECTED_APPLICATION:
                                self.viewModel.applicationState = .rejected
                                
                            // Subcondition 3 -- AuthenticationCode wasn't supplied or is invalid
                            case .BAD_REQUEST:
                                break
                                
                            // Subcondition 4 -- Other.
                            default: 
                                break
                        }
                }
            }
        }
        VULogger.log("Added refresh logic")
        
        viewModel.cancelApplicationAndRemoveReceipt = { [weak self] in 
            self?.viewModel.applicationReceipt = nil
            self?.component.onboardingServiceProxy.backing?.cancelApplication()
            self?.component.keychainStorageServicing.remove(for: .KEYCHAIN_KEY_FOR_FPONBOARDINGSERVICE_MEMENTO_SNAPSHOT)
        }
        VULogger.log("Added cancel logic")
        
        viewModel.queOperationalFlow = { [weak self] in
            self?.component.keychainStorageServicing.remove(for: .KEYCHAIN_KEY_FOR_FPONBOARDINGSERVICE_MEMENTO_SNAPSHOT)
            self?.listener?.didFinishPairing()
        }
        VULogger.log("Added que to operations logic")
        
        viewModel.refreshApplicationStatus?()
    }
    
}



extension OnboardingInteractor {
    
    
    func didFinishPairing() {
        guard
            component.networkingClientProxy.isBacked,
            let onboardingService = component.onboardingServiceProxy.backing,
            case .success = component.keychainStorageServicing.retrieve(for: .KEYCHAIN_KEY_FOR_NETWORKING_CLIENT_MEMENTO_SNAPSHOT, limit: 1),
            case .success = component.keychainStorageServicing.retrieve(for: .KEYCHAIN_KEY_FOR_FPONBOARDINGSERVICE_MEMENTO_SNAPSHOT, limit: 1)
        else {
            fatalError("All must be set before onboarding can complete")
        }
        
        configureViewModelForOngoingPendingApplication()
        router?.exitFlow()
    }
    
    
    func didNotPair() {
        router?.exitFlow()
    }
    
}



/// Conformance to the ``OnboardingPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``OnboardingViewController``.
extension OnboardingInteractor: OnboardingPresentableListener {}
