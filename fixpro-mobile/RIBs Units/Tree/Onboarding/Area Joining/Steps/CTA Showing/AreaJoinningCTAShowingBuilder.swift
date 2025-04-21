import RIBs
import VinUtility



/// An empty set of properties. As the ancestral RIB, 
/// `AreaJoinningCTAShowingRIB` does not require any dependencies from its parent scope.
protocol AreaJoinningCTAShowingDependency: Dependency {
    var keychainStorageServicing: any FPTextStorageServicing { get }
    var networkingClientProxy: any VUProxy<FPNetworkingClient> { get }
    var networkingClientMementoAgentProxy: any VUProxy<FPMementoAgent<FPNetworkingClient, FPNetworkingClientSnapshot>> { get }
    var onboardingService: FPOnboardingServicing  { get }
    var onboardingServiceMementoAgentProxy: any VUProxy<FPMementoAgent<FPOnboardingService, FPOnboardingServiceSnapshot>> { get }
}



/// Concrete implementation of the ``AreaJoinningCTAShowingDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``AreaJoinningCTAShowingRouter``.
final class AreaJoinningCTAShowingComponent: Component<AreaJoinningCTAShowingDependency> {
    
    
    /// Constructs a singleton instance of ``AreaJoinningCTAShowingViewController``.
    var areaJoinningCTAShowingViewController: AreaJoinningCTAShowingViewControllable & AreaJoinningCTAShowingPresentable {
        shared { AreaJoinningCTAShowingViewController() }
    }
    
    
    /// Keychain storage.
    var keychainStorageServicing: any FPTextStorageServicing {
        dependency.keychainStorageServicing
    }
    
    
    // MARK: -- Networking Client
    
    /// Proxy to the object that performs the network operations.
    /// 
    /// Passed in, so that upon flow change, this proxy has its backing object backed.
    var networkingClientProxy: any VUProxy<FPNetworkingClient> {
        dependency.networkingClientProxy
    }
    
    
    /// Proxy to the object that snaps the backing object of ``networkingClientProxy`` and saves it to storage of choice.
    var networkingClientMementoAgentProxy: any VUProxy<FPMementoAgent<FPNetworkingClient, FPNetworkingClientSnapshot>> {
        dependency.networkingClientMementoAgentProxy
    }
    
    
    // MARK: -- Onboarding Service
    
    /// The proxy to the object that is integral to complete the onboarding process.
    var onboardingService: FPOnboardingServicing  {
        dependency.onboardingService
    }
    
    
    /// Proxy to the object that snaps the backing object of ``onboardingServiceProxy`` and saves it to storage of choice.
    var onboardingServiceMementoAgentProxy: any VUProxy<FPMementoAgent<FPOnboardingService, FPOnboardingServiceSnapshot>> {
        dependency.onboardingServiceMementoAgentProxy
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension AreaJoinningCTAShowingComponent {}



/// Contract adhered to by ``AreaJoinningCTAShowingBuilder``, listing necessary actions to
/// construct a functional `AreaJoinningCTAShowingRIB`.
protocol AreaJoinningCTAShowingBuildable: Buildable {
    
    
    /// Constructs the `AreaJoinningCTAShowingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: AreaJoinningCTAShowingListener) -> AreaJoinningCTAShowingRouting
    
}



/// The composer of `AreaJoinningCTAShowingRIB`.
final class AreaJoinningCTAShowingBuilder: Builder<AreaJoinningCTAShowingDependency>, AreaJoinningCTAShowingBuildable {
    
    
    /// Creates an instance of ``AreaJoinningCTAShowingBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: AreaJoinningCTAShowingDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `AreaJoinningCTAShowingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: AreaJoinningCTAShowingListener) -> AreaJoinningCTAShowingRouting {
        let component  = AreaJoinningCTAShowingComponent(dependency: dependency)
        let interactor = AreaJoinningCTAShowingInteractor(component: component)
            interactor.listener = listener
        
        return AreaJoinningCTAShowingRouter(
            interactor: interactor, 
            viewController: component.areaJoinningCTAShowingViewController
        )
    }
    
}
