import RIBs
import VinUtility



/// An empty set of properties. As the ancestral RIB, 
/// `AreaJoinningCTAShowingRIB` does not require any dependencies from its parent scope.
protocol AreaJoinningCTAShowingDependency: Dependency {
    var sessionIdentityServiceProxy: any VUProxy<FPSessionIdentityServicing> { get }
    var bootstraperService: FPBootstrapperServicing & VUMementoSnapshotable { get }
}



/// Concrete implementation of the ``AreaJoinningCTAShowingDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``AreaJoinningCTAShowingRouter``.
final class AreaJoinningCTAShowingComponent: Component<AreaJoinningCTAShowingDependency> {
    
    
    /// Constructs a singleton instance of ``AreaJoinningCTAShowingViewController``.
    var areaJoinningCTAShowingViewController: AreaJoinningCTAShowingViewControllable & AreaJoinningCTAShowingPresentable {
        shared { AreaJoinningCTAShowingViewController() }
    }
    
    
    var sessionIdentityServiceProxy: any VUProxy<FPSessionIdentityServicing> {
        dependency.sessionIdentityServiceProxy
    }
    
    
    var bootstraperService: FPBootstrapperServicing & VUMementoSnapshotable {
        dependency.bootstraperService
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
