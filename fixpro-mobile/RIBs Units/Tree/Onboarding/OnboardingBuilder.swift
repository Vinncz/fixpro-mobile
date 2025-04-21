import RIBs
import VinUtility



/// An empty set of properties. As the ancestral RIB, 
/// `OnboardingRIB` does not require any dependencies from its parent scope.
protocol OnboardingDependency: Dependency {
    var keychainStorageServicing: any FPTextStorageServicing { get }
    var networkingClientProxy: any VUProxy<FPNetworkingClient> { get }
    var sessionIdentityServiceProxy: any VUProxy<FPSessionIdentityServicing> { get }
    var sessionIdentityServiceMementoAgentProxy: any VUProxy<FPMementoAgent<FPSessionIdentityService, FPSessionIdentityServiceSnapshot>> { get }
    var sessionIdentityUpkeeperProxy: any VUProxy<FPSessionIdentityUpkeeping> { get }
}



/// Concrete implementation of the ``OnboardingDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``OnboardingRouter``.
final class OnboardingComponent: Component<OnboardingDependency> {
    
    
    var onboardingViewController: OnboardingViewControllable & OnboardingPresentable {
        shared { OnboardingViewController() }
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
        shared { VUProxyObject() }
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
    
    
    /// Proxy to the object that performs tokens renewal.
    var sessionIdentityUpkeeperProxy: any VUProxy<FPSessionIdentityUpkeeping> {
        shared { VUProxyObject() }
    }
    
    
    // MARK: -- Onboarding Service
    
    /// The object that is integral to complete the onboarding process.
    var onboardingServiceProxy: any VUProxy<FPOnboardingServicing> {
        shared { VUProxyObject() }
    }
    
    
    /// Proxy to the object that snaps the backing object of ``onboardingServiceProxy`` and saves it to storage of choice.
    var onboardingServiceMementoAgentProxy: any VUProxy<FPMementoAgent<FPOnboardingService, FPOnboardingServiceSnapshot>> {
        shared { VUProxyObject() }
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension OnboardingComponent: AreaJoinningDependency {}



/// Contract adhered to by ``OnboardingBuilder``, listing necessary actions to
/// construct a functional `OnboardingRIB`.
protocol OnboardingBuildable: Buildable {
    
    
    /// Constructs the `OnboardingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: OnboardingListener) -> OnboardingRouting
    
}



/// The composer of `OnboardingRIB`.
final class OnboardingBuilder: Builder<OnboardingDependency>, OnboardingBuildable {
    
    
    /// Creates an instance of ``OnboardingBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: OnboardingDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `OnboardingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: OnboardingListener) -> OnboardingRouting {
        let component  = OnboardingComponent(dependency: dependency)
        let interactor = OnboardingInteractor(component: component)
            interactor.listener = listener
        
        return OnboardingRouter(
            interactor: interactor, 
            viewController: component.onboardingViewController,
            areaJoinningBuilder: AreaJoinningBuilder(dependency: component)
        )
    }
    
}
