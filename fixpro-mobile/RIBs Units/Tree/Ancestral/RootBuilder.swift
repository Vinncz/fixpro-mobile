import RIBs
import VinUtility



/// An empty set of properties. As the ancestral RIB, 
/// `RootRIB` does not require any dependencies from its parent scope.
protocol RootDependency: Dependency {}
extension EmptyComponent: RootDependency {}



/// Concrete implementation of the ``RootDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``RootRouter``.
final class RootComponent: Component<RootDependency> {
    
    
    /// Keychain storage.
    var keychainStorageServicing: any FPTextStorageServicing {
        shared { FPKeychainQueristServiceFPTextStorageServicingAdapter(FPKeychainQueristService()) }
    }
    
    
    /// Object that verifies pairing state to an Area.
    var bootstrappedVerifierService: FPBootstrappedVerifierServicing {
        shared { FPBootstrapedVerifierService(storage: keychainStorageServicing) }
    }
    
    
    /// Proxy to the object that performs the network operations.
    var networkingClientProxy: any VUProxy<FPNetworkingClient> {
        shared { VUProxyObject() }
    }
    
    
    /// Proxy to the object that holds the credentials needed for a majority of network operations.
    var sessionIdentityServiceProxy: any VUProxy<FPSessionIdentityServicing> {
        shared { VUProxyObject() }
    }
    
    
    /// Proxy to the object that snaps the backing object of ``sessionIdentityServiceProxy`` and saves it to storage of choice.
    var sessionIdentityServiceMementoAgentProxy: any VUProxy<FPMementoAgent<FPSessionIdentityService, FPSessionIdentityServiceSnapshot>> {
        shared { VUProxyObject() }
    }
    
    
    /// Proxy to the object that performs tokens renewal.
    var sessionIdentityUpkeeperProxy: any VUProxy<FPSessionIdentityUpkeeping> {
        shared { VUProxyObject() }
    }
    
}



/// Conformance extension to this RIB's children's `Dependency` protocols.
extension RootComponent: OnboardingDependency, OperationsDependency {
    
    
    var sessionIdentityService: any FPSessionIdentityServicing {
        sessionIdentityServiceProxy.backing!
    }
    
    
    var sessionIdentityServiceMementoAgent: FPMementoAgent<FPSessionIdentityService, FPSessionIdentityServiceSnapshot> {
        sessionIdentityServiceMementoAgentProxy.backing!
    }
    
    
    var sessionidentityServiceUpkeeper: any FPSessionIdentityUpkeeping {
        sessionIdentityUpkeeperProxy.backing!
    }
    
}



/// Contract adhered to by ``RootBuilder``, listing necessary actions to
/// construct a functional `RootRIB`.
protocol RootBuildable: Buildable {
    
    
    /// Constructs the `RootRIB`.
    func build() -> LaunchRouting
    
}



/// The composer of `RootRIB`.
final class RootBuilder: Builder<RootDependency>, RootBuildable {
    
    
    /// Creates an instance of ``RootBuilder``.
    init() { super.init(dependency: EmptyComponent()) }
    
    
    /// Constructs the `RootRIB`.
    func build() -> LaunchRouting {
        let viewController = RootViewController()
        let component  = RootComponent(dependency: dependency)
        let interactor = RootInteractor(component: component, presenter: viewController)
        
        return RootRouter(
            interactor: interactor, 
            viewController: viewController,
            onboardingBuilder: OnboardingBuilder(dependency: component),
            operationsBuilder: OperationsBuilder(dependency: component)
        )
    }
    
}
