import RIBs
import VinUtility



/// A set of properties that are required by `AreaJoinningRIB` to function, 
/// supplied from the scope of its parent.
protocol AreaJoinningDependency: Dependency {
    var keychainStorageServicing: any FPTextStorageServicing { get }
    var sessionIdentityServiceProxy: any VUProxy<FPSessionIdentityServicing> { get }
    var sessionIdentityServiceMementoAgentProxy: any VUProxy<FPMementoAgent<FPSessionIdentityService, FPSessionIdentityServiceSnapshot>> { get }
    var networkingClientProxy: any VUProxy<FPNetworkingClient> { get }
    var networkingClientMementoAgentProxy: any VUProxy<FPMementoAgent<FPNetworkingClient, FPNetworkingClientSnapshot>> { get }
    var onboardingServiceProxy: any VUProxy<FPOnboardingServicing>  { get }
    var onboardingServiceMementoAgentProxy: any VUProxy<FPMementoAgent<FPOnboardingService, FPOnboardingServiceSnapshot>> { get }
}



/// Concrete implementation of the ``AreaJoinningDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``AreaJoinningRouter``.
final class AreaJoinningComponent: Component<AreaJoinningDependency> {
    
    
    /// Constructs a singleton instance of ``AreaJoinningViewController``.
    var areaJoinningViewController: AreaJoinningViewControllable & AreaJoinningPresentable {
        shared { AreaJoinningViewController() }
    }
    
    
    /// Keychain storage.
    var keychainStorageServicing: any FPTextStorageServicing {
        dependency.keychainStorageServicing
    }
    
    
    // MARK: -- Networking Client
    
    /// Proxy to the object that performs the network operations.
    var networkingClientProxy: any VUProxy<FPNetworkingClient> {
        dependency.networkingClientProxy
    }
    
    
    /// Proxy to the object that snaps the backing object of ``networkingClientProxy`` and saves it to storage of choice.
    var networkingClientMementoAgentProxy: any VUProxy<FPMementoAgent<FPNetworkingClient, FPNetworkingClientSnapshot>> {
        dependency.networkingClientMementoAgentProxy
    }
    
    
    // MARK: -- Session Identity
    
    /// Proxy to the object that holds the credentials needed for a majority of network operations.
    var sessionIdentityServiceProxy: any VUProxy<FPSessionIdentityServicing> {
        dependency.sessionIdentityServiceProxy
    }
    
    
    /// Proxy to the object that snaps the backing object of ``sessionIdentityServiceProxy`` and saves it to storage of choice.
    var sessionIdentityServiceMementoAgentProxy: any VUProxy<FPMementoAgent<FPSessionIdentityService, FPSessionIdentityServiceSnapshot>> {
        dependency.sessionIdentityServiceMementoAgentProxy
    }
    
    
    // MARK: -- Onboarding Service
    
    /// The proxy to the object that is integral to complete the onboarding process.
    var onboardingServiceProxy: any VUProxy<FPOnboardingServicing>  {
        dependency.onboardingServiceProxy
    }
    
    
    /// Proxy to the object that snaps the backing object of ``onboardingServiceProxy`` and saves it to storage of choice.
    var onboardingServiceMementoAgentProxy: any VUProxy<FPMementoAgent<FPOnboardingService, FPOnboardingServiceSnapshot>> {
        dependency.onboardingServiceMementoAgentProxy
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension AreaJoinningComponent: AreaJoinningCodeScanningDependency, AreaJoinningFormFillingDependency, AreaJoinningCTAShowingDependency {
    
    
    /// The assumed-to-be-not-nil backing object of the ``onboardingServiceProxy``.
    var onboardingService: FPOnboardingServicing {
        onboardingServiceProxy.backing!
    } 
    
}



/// Contract adhered to by ``AreaJoinningBuilder``, listing necessary actions to
/// construct a functional `AreaJoinningRIB`.
protocol AreaJoinningBuildable: Buildable {
    
    
    /// Constructs the `AreaJoinningRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: AreaJoinningListener) -> AreaJoinningRouting
    
}



/// The composer of `AreaJoinningRIB`.
final class AreaJoinningBuilder: Builder<AreaJoinningDependency>, AreaJoinningBuildable {
    
    
    /// Creates an instance of ``AreaJoinningBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: AreaJoinningDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `AreaJoinningRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: AreaJoinningListener) -> AreaJoinningRouting {
        let component  = AreaJoinningComponent(dependency: dependency)
        let interactor = AreaJoinningInteractor(component: component)
            interactor.listener = listener
        
        return AreaJoinningRouter(
            interactor: interactor, 
            viewController: component.areaJoinningViewController,
            areaJoinningCodeScanningBuilder: AreaJoinningCodeScanningBuilder(dependency: component),
            areaJoinningFormFillingBuilder: AreaJoinningFormFillingBuilder(dependency: component),
            areaJoinningCTAShowingBuilder: AreaJoinningCTAShowingBuilder(dependency: component)
        )
    }
    
}
