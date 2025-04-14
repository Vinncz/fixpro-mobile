import RIBs
import VinUtility



/// An empty set of properties. As the ancestral RIB, 
/// `RootRIB` does not require any dependencies from its parent scope.
protocol RootDependency: Dependency {}
extension EmptyComponent: RootDependency {}



/// Concrete implementation of the ``RootDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``RootRouter``.
final class RootComponent: Component<RootDependency> {
    
    
    var rootViewController: RootViewControllable & RootPresentable & OperationsViewControllable {
        shared { RootViewController() }
    }
    
    
    var keychainStorageServicing: FPKeychainQueristServiceFPTextStorageServicingAdapter {
        shared { FPKeychainQueristServiceFPTextStorageServicingAdapter(FPKeychainQueristService()) }
    }
    
    
    var bootstrappedVerifierService: FPBootstrappedVerifierServicing {
        shared { FPBootstrapedVerifierService(storage: keychainStorageServicing) }
    }
    
    
    var networkingClientProxy: any VUProxy<FPNetworkingClient> {
        shared { VUProxyObject() }
    }
    
    
    var sessionIdentityServiceProxy: any VUProxy<FPSessionIdentityServicing> {
        shared { VUProxyObject() }
    }
    
    
    var sessionIdentityServiceMementoAgentProxy: any VUProxy<FPSessionIdetityServiceMementoAgent> {
        shared { VUProxyObject() }
    }
    
}



/// Conformance extension to this RIB's children's `Dependency` protocols.
extension RootComponent: BootstrapDependency, OperationsDependency {
    
    var operationsViewController: any OperationsViewControllable {
        rootViewController
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
        let component  = RootComponent(dependency: dependency)
        let interactor = RootInteractor(component: component)
        
        return RootRouter(
            interactor: interactor, 
            viewController: component.rootViewController,
            bootstrapBuilder: BootstrapBuilder(dependency: component),
            operationsBuilder: OperationsBuilder(dependency: component)
        )
    }
    
}
