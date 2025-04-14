import Foundation
import RIBs
import RxSwift
import VinUtility



/// Contract adhered to by ``BootstrapRouter``, listing the attributes and/or actions 
/// that ``BootstrapInteractor`` is allowed to access or invoke.
protocol BootstrapRouting: ViewableRouting {
    func pairingFlow()
    func exitFlow()
}



/// Contract adhered to by ``BootstrapViewController``, listing the attributes and/or actions
/// that ``BootstrapInteractor`` is allowed to access or invoke.
protocol BootstrapPresentable: Presentable {
    
    
    /// Reference to ``BootstrapInteractor``.
    var presentableListener: BootstrapPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: BootstrapSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `BootstrapRIB`'s parent, listing the attributes and/or actions
/// that ``BootstrapInteractor`` is allowed to access or invoke.
protocol BootstrapListener: AnyObject {
    func didFinishPairing()
}



/// The functionality centre of `BootstrapRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class BootstrapInteractor: PresentableInteractor<BootstrapPresentable>, BootstrapInteractable {
    
    
    /// Reference to ``BootstrapRouter``.
    weak var router: BootstrapRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: BootstrapListener?
    
    
    /// Reference to the component of this RIB.
    var component: BootstrapComponent
    
    
    /// Bridge to the ``BootstrapSwiftUIVIew``.
    private var viewModel = BootstrapSwiftUIViewModel()
    
    
    /// Constructs an instance of ``BootstrapInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: BootstrapComponent) {
        self.component = component
        let presenter = component.bootstrapViewController
        
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
    
    
    /// Configures the view model.
    private func configureViewModel() {
        switch component.bootstrapperServiceMementoAgent.restore(to: FPBootstrapperServiceSnapshot.self) {
                
            // Condition 1 -- FixPro Mobile did attempt pairing, and should be continuing where it left off.
            case .success(let snapshot):
                switch component.bootstraperService.restore(from: snapshot) {
                    case .success: 
                        VULogger.log("Successfully restored BootstrapService from snapshot.")
                    case .failure(let error):
                        VULogger.log(tag: .error, "Error in restoring from a snapshot: \(error)")
                }
                configureSuccessfulViewModel(snapshot)
                
                
            // Condition 2 -- FixPro Mobile has not attempted any pairing.
            case .failure:
                break
                
        }
        
        viewModel.quePairingFlow = { [weak self] in
            self?.router?.pairingFlow()
        }
        
        presenter.bind(viewModel: self.viewModel)
    }
    
}



extension BootstrapInteractor {
    
    
    func configureSuccessfulViewModel(_ snapshot: FPBootstrapperServiceSnapshot) {
        viewModel.applicationReceipt = .init(areaName: snapshot.areaName, 
                                             appliedOnDate: snapshot.applicationSubmissionDate, 
                                             offerExpiryDate: snapshot.applicationIdExpiryDate)
        VULogger.log("Added ApplicationReceipt")
        
        viewModel.applicationState = .undecided
        
        viewModel.refreshApplicationStatus = { [weak self] in 
            guard 
                self?.viewModel.applicationState != .approvedAndReadyForTransition 
             && self?.viewModel.applicationState != .rejected 
            else { return }
            
            Task {
                switch await self?.component.bootstraperService.checkApplicationStatus() {
                    
                    // Condition 1 -- Self application has been approved, and is now getting an authenticationCode to start
                    //                communicating with the backend more.
                    case .success(let authenticationCode):
                        guard 
                            let self,
                            let endpoint = self.component.bootstraperService.endpoint,
                            let endpointURL = URL(string: endpoint)
                        else { return }
                        
                        VULogger.log("Application approved")
                        
                        switch await FPSessionIdentityService.exhangeForTokens(authenticationCode: authenticationCode, endpoint: endpointURL) {
                            
                            // Subcondition 1 -- Successful exchange. Only invoked once.
                            case .success(let sessionIdentityService):
                                VULogger.log("Successful token exchange")
                                
                                // <Prep for flow change>
                                self.component.sessionIdentityServiceProxy.back(with: sessionIdentityService)
                                
                                let sessionIdentityServiceMementoAgent = FPSessionIdetityServiceMementoAgent(storage: self.component.keychainStorageServicing, 
                                                                                                             target: sessionIdentityService as? VUMementoSnapshotable)
                                self.component.sessionIdentityServiceMementoAgentProxy.back(with: sessionIdentityServiceMementoAgent)
                                
                                sessionIdentityServiceMementoAgent.takeSnapshot(tag: nil)
                                
                                self.component.networkingClientProxy.back(with: FPNetworkingClient(endpoint: endpointURL))
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
                                        
                                        self.component.bootstraperService.cancelApplication()
                                        self.viewModel.applicationReceipt = nil
                                        self.component.bootstrapperServiceMementoAgent.remove()
                                    
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
                        
                        
                    // Condition 3 -- Self is nil. Unlikely to happen.
                    case .none:
                        VULogger.log(tag: .warning, "Reached here. How?")
                }
            }
        }
        VULogger.log("Added refresh logic")
        
        viewModel.cancelApplicationAndRemoveReceipt = { [weak self] in 
            self?.viewModel.applicationReceipt = nil
            self?.component.bootstraperService.cancelApplication()
            self?.component.keychainStorageServicing.remove(for: .KEYCHAIN_KEY_FOR_FPBOOTSTRAPPER_MEMENTO_SNAPSHOT)
        }
        VULogger.log("Added cancel logic")
        
        viewModel.queOperationalFlow = { [weak self] in
            self?.component.keychainStorageServicing.remove(for: .KEYCHAIN_KEY_FOR_FPBOOTSTRAPPER_MEMENTO_SNAPSHOT)
            self?.listener?.didFinishPairing()
        }
        VULogger.log("Added que to operations logic")
        
        viewModel.refreshApplicationStatus?()
    }
    
}



extension BootstrapInteractor {
    
    
    func didFinishPairing() {
        guard
            let areaName = component.bootstraperService.areaName,
            let applicationId = component.bootstraperService.applicationId,
            let applicationSubmissionDate = component.bootstraperService.applicationSubmissionDate,
            let applicationExpiryDate = component.bootstraperService.applicationIdExpiryDate,
            let endpoint = component.bootstraperService.endpoint
        else {
            return
        }
        
        configureSuccessfulViewModel(.init(areaName: areaName, applicationId: applicationId, applicationSubmissionDate: applicationSubmissionDate, applicationIdExpiryDate: applicationExpiryDate, endpoint: endpoint))
        router?.exitFlow()
    }
    
    
    func didNotPair() {
        router?.exitFlow()
    }
    
}



/// Conformance to the ``BootstrapPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``BootstrapViewController``.
extension BootstrapInteractor: BootstrapPresentableListener {}
