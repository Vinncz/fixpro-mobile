import RIBs
import VinUtility



/// An empty set of properties. As the ancestral RIB, 
/// `BootstrapRIB` does not require any dependencies from its parent scope.
protocol BootstrapDependency: Dependency {
    var keychainStorageServicing: FPKeychainQueristServiceFPTextStorageServicingAdapter { get }
    var networkingClientProxy: any VUProxy<FPNetworkingClient> { get }
    var sessionIdentityServiceProxy: any VUProxy<FPSessionIdentityServicing> { get }
    var sessionIdentityServiceMementoAgentProxy: any VUProxy<FPSessionIdetityServiceMementoAgent> { get }
}



/// Concrete implementation of the ``BootstrapDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``BootstrapRouter``.
final class BootstrapComponent: Component<BootstrapDependency> {
    
    
    var bootstrapViewController: BootstrapViewControllable & BootstrapPresentable {
        shared { BootstrapViewController() }
    }
    
    
    var bootstraperService: FPBootstrapperServicing & VUMementoSnapshotable {
        shared { FPBootstrapperService() }
    }
    
    
    var bootstrapperServiceMementoAgent: FPBootstrapperServiceMementoAgent {
        shared { FPBootstrapperServiceMementoAgent(storage: dependency.keychainStorageServicing, target: bootstraperService) }
    }
    
    
    var keychainStorageServicing: FPKeychainQueristServiceFPTextStorageServicingAdapter {
        dependency.keychainStorageServicing
    }
    
    
    var networkingClientProxy: any VUProxy<FPNetworkingClient> {
        dependency.networkingClientProxy
    }
    
    
    var sessionIdentityServiceProxy: any VUProxy<FPSessionIdentityServicing> {
        dependency.sessionIdentityServiceProxy
    }
    
    
    var sessionIdentityServiceMementoAgentProxy: any VUProxy<FPSessionIdetityServiceMementoAgent> {
        dependency.sessionIdentityServiceMementoAgentProxy
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension BootstrapComponent: AreaJoinningDependency {}



/// Contract adhered to by ``BootstrapBuilder``, listing necessary actions to
/// construct a functional `BootstrapRIB`.
protocol BootstrapBuildable: Buildable {
    
    
    /// Constructs the `BootstrapRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: BootstrapListener) -> BootstrapRouting
    
}



/// The composer of `BootstrapRIB`.
final class BootstrapBuilder: Builder<BootstrapDependency>, BootstrapBuildable {
    
    
    /// Creates an instance of ``BootstrapBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: BootstrapDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `BootstrapRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: BootstrapListener) -> BootstrapRouting {
        let component  = BootstrapComponent(dependency: dependency)
        let interactor = BootstrapInteractor(component: component)
            interactor.listener = listener
        
        return BootstrapRouter(
            interactor: interactor, 
            viewController: component.bootstrapViewController,
            areaJoinningBuilder: AreaJoinningBuilder(dependency: component)
        )
    }
    
}
