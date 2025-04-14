import RIBs
import VinUtility
import OpenAPIURLSession
import RxSwift



/// Contract adhered to by ``RootRouter``, listing the attributes and/or actions 
/// that ``RootInteractor`` is allowed to access or invoke.
protocol RootRouting: ViewableRouting {
    func operationalFlow()
    func bootstrappingFlow()
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
    init(component: RootComponent) {
        self.component = component
        let presenter = component.rootViewController
        
        super.init(presenter: presenter)
        
        presenter.presentableListener = self
    }
    
    
    /// Customization point that is invoked after self becomes active.
    override func didBecomeActive() {
        super.didBecomeActive()
        
        switch component.bootstrappedVerifierService.verifyBootstrapped() {
            case .success(let tuple):
                VULogger.log("Commencing operations flow")
                
                // Step 0 -- Clean up a probable messy bootstrapping flow
                component.keychainStorageServicing.remove(for: .KEYCHAIN_KEY_FOR_FPBOOTSTRAPPER_MEMENTO_SNAPSHOT)
                
                // Step 1 -- Prep for networking
                let networkingClient = FPNetworkingClient(endpoint: tuple.endpoint)
                self.component.networkingClientProxy.back(with: networkingClient)
                
                // Step 2 -- Load credentials into memory
                let sessionIdentityService = FPSessionIdentityService(refreshToken: tuple.refreshToken, networkingClient: networkingClient)
                self.component.sessionIdentityServiceProxy.back(with: sessionIdentityService)
                
                // Step 3 -- Ready the memento agents
                let sessionIdentityServiceMementoAgent = FPSessionIdetityServiceMementoAgent(storage: component.keychainStorageServicing, target: sessionIdentityService)
                self.component.sessionIdentityServiceMementoAgentProxy.back(with: sessionIdentityServiceMementoAgent)
                
                // Step 4 -- It's go time
                router?.operationalFlow()
                
            case .failure:
                VULogger.log("Commencing bootstrapping flow")
                
                router?.bootstrappingFlow()
                
        }
    }
    
    
    /// Customization point that is invoked before self is fully detached.
    override func willResignActive() {
        super.willResignActive()
    }
    
}



/// Conformance to the ``BootstrapListener`` protocol.
/// Contains everything accesible or invokable by ``BootstrapInteractor``.
extension RootInteractor {
    
    
    /// Detaches the `BootstrapRIB` and replaces it with `OperationsRIB`.
    /// 
    /// When switching between flows, it guards the following to be true:
    /// - ``RootComponent/networkingClientProxy`` is operational,
    /// - ``RootComponent/sessionIdentityServiceProxy`` is operational, and
    /// - ``RootComponent/sessionIdentityServiceMementoAgentProxy`` is operational.
    func didFinishPairing() {
        guard
            component.networkingClientProxy.isBacked,
            component.sessionIdentityServiceProxy.isBacked,
            component.sessionIdentityServiceMementoAgentProxy.isBacked
        else { 
            VULogger.log(tag: .critical, "Not all required proxies have been initialized. Solve this in debug before going to production.")
            return 
        }
        
        router?.operationalFlow()
    }
    
}



/// Conformance to the ``OperationsListener`` protocol.
/// Contains everything accesible or invokable by ``OperationsInteractor``.
extension RootInteractor {
    
    
    /// Detaches the `OperationsRIB` and replaces it with `BootstrapRIB`.
    func didLogOut() {
        router?.bootstrappingFlow()
    }
    
}



/// Conformance to the ``RootPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``RootViewController``.
extension RootInteractor: RootPresentableListener {}
