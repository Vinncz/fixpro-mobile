import RIBs
import RxSwift
import VinUtility



/// Contract adhered to by ``RootRouter``, listing the attributes and/or actions 
/// that ``RootInteractor`` is allowed to access or invoke.
protocol RootRouting: ViewableRouting {
    func operationalFlow(fromNotification: FPNotificationDigest?)
    func onboardingFlow()
    func clearAllFlows()
}



/// Contract adhered to by ``RootViewController``, listing the attributes and/or actions
/// that ``RootInteractor`` is allowed to access or invoke.
protocol RootPresentable: Presentable {
    
    
    /// Reference to ``RootInteractor``.
    var presentableListener: RootPresentableListener? { get set }
    
}



/// Contract adhered to by the Interactor of `RootRIB`'s parent, listing the attributes and/or actions
/// that ``RootInteractor`` is allowed to access or invoke.
protocol RootListener: AnyObject {}



/// The functionality centre of `RootRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class RootInteractor: PresentableInteractor<RootPresentable>, RootInteractable {
    
    
    /// Reference to ``RootRouter``.
    weak var router: RootRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: RootListener?
    
    
    /// Reference to the component of this RIB.
    var component: RootComponent
    
    
    /// Constructs an instance of ``RootInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: RootComponent, presenter: RootPresentable) {
        self.component = component
        
        super.init(presenter: presenter)
        
        presenter.presentableListener = self
    }
    
    
    /// 
    var isBootstrapped: Bool = false
    
    
    /// Customization point that is invoked after self becomes active.
    override func didBecomeActive() {
        super.didBecomeActive()
        
        switch component.bootstrappedVerifierService.verifyBootstrapped() {
        case .success(let snapshots):
            isBootstrapped = true
            VULogger.log("Commencing operations flow")
            
            
            // Step 0 -- Clean up a probable mess of the onboarding flow.
            component.keychainStorageServicing.remove(for: .KEYCHAIN_KEY_FOR_FPONBOARDINGSERVICE_MEMENTO_SNAPSHOT)
            
            
            // Step 1 -- Prep for networking
            // Substep 1 -- Load the credentials.
               let sessionIdentityServicing = FPSessionIdentityService.boot(fromSnapshot: snapshots.sessionIdentity).get()
               component.sessionIdentityServiceProxy.back(with: sessionIdentityServicing)
                
               let sessionIdentityServiceMementoAgent = FPMementoAgent<FPSessionIdentityService, FPSessionIdentityServiceSnapshot>(storage: component.keychainStorageServicing, 
                                                                                                                                   target: sessionIdentityServicing, 
                                                                                                                                   storageKey: .KEYCHAIN_KEY_FOR_FPSESSION_IDENTITY_MEMENTO_SNAPSHOT)
               component.sessionIdentityServiceMementoAgentProxy.back(with: sessionIdentityServiceMementoAgent)
               
               
            // Substep 2 -- Boot the networking client.
               let sessionIdentityMiddleware = FPSessionIdentityMiddleware(storage: sessionIdentityServicing)
               let loggerMiddleware = FPLoggerMiddleware()
               let networkingClient = FPNetworkingClient(endpoint: snapshots.networkingClient.endpoint, middlewares: [sessionIdentityMiddleware, loggerMiddleware])
               component.networkingClientProxy.back(with: networkingClient)
                   
                   
            // Substep 3 -- Pair the upkeeper of credentials with the client (to renew) and the storage (so it updates them).
               let sessionIdentityUpkeeper = FPSessionIdentityUpkeeper(storage: sessionIdentityServicing, networkingClient: networkingClient, mementoAgent: sessionIdentityServiceMementoAgent)
               component.sessionIdentityUpkeeperProxy.back(with: sessionIdentityUpkeeper)
              
              
            // Step 2 -- It's go time
            router?.operationalFlow(fromNotification: nil)
            
        case .failure:
            isBootstrapped = false
            VULogger.log("Commencing onboarding flow")
            
            router?.onboardingFlow()
            
        }
    }
    
    
    /// Customization point that is invoked before self is fully detached.
    override func willResignActive() {
        super.willResignActive()
    }
    
    
    /// Routes to a destination specified by the notification digest.
    /// 
    /// - Parameter notification: The notification responsible for citing deeplinking.
    func deeplink(notification: FPNotificationDigest) {
        guard isBootstrapped else { return }
        
        router?.operationalFlow(fromNotification: notification)
    }
    
}



/// Conformance to the ``OnboardingListener`` protocol.
/// Contains everything accesible or invokable by ``OnboardingInteractor``.
extension RootInteractor {
    
    
    /// Detaches the `OnboardingRIB` and replaces it with `OperationsRIB`.
    /// 
    /// When switching between flows, it guards the following to be true:
    /// - ``RootComponent/networkingClientProxy`` is operational,
    /// - ``RootComponent/sessionIdentityServiceProxy`` is operational, and
    /// - ``RootComponent/sessionIdentityServiceMementoAgentProxy`` is operational.
    func didFinishPairing() {
        guard
            component.networkingClientProxy.isBacked &&
            component.sessionIdentityServiceProxy.isBacked &&
            component.sessionIdentityServiceMementoAgentProxy.isBacked &&
            component.sessionIdentityUpkeeperProxy.isBacked
        else { 
            VULogger.log(tag: .critical, "Not all required proxies have been initialized. Solve this in debug before going to production.")
            VULogger.log(component.networkingClientProxy.isBacked, component.sessionIdentityServiceProxy.isBacked, component.sessionIdentityServiceMementoAgentProxy.isBacked, component.sessionIdentityUpkeeperProxy.isBacked)
            return 
        }
        
        isBootstrapped = true
        router?.clearAllFlows()
        router?.operationalFlow(fromNotification: nil)
    }
    
}



/// Conformance to the ``OperationsListener`` protocol.
/// Contains everything accesible or invokable by ``OperationsInteractor``.
extension RootInteractor {
    
    
    /// Detaches the `OperationsRIB` and replaces it with `OnboardingRIB`.
    /// 
    /// The RIB who invoked this method MUST ensure the cleanup of every last traces of pairing.
    func didIntendLogOut() {
        router?.clearAllFlows()
        isBootstrapped = false
        router?.onboardingFlow()
    }
    
}



/// Conformance to the ``RootPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``RootViewController``.
extension RootInteractor: RootPresentableListener {}
