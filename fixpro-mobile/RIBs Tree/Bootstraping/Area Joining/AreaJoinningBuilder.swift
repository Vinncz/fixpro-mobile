import RIBs
import VinUtility



/// A set of properties that are required by `AreaJoinningRIB` to function, 
/// supplied from the scope of its parent.
protocol AreaJoinningDependency: Dependency {
    var sessionIdentityServiceProxy: any VUProxy<FPSessionIdentityServicing> { get }
    var bootstraperService: FPBootstrapperServicing & VUMementoSnapshotable { get }
    var bootstrapperServiceMementoAgent: FPBootstrapperServiceMementoAgent { get }
}



/// Concrete implementation of the ``AreaJoinningDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``AreaJoinningRouter``.
final class AreaJoinningComponent: Component<AreaJoinningDependency> {
    
    
    /// Constructs a singleton instance of ``AreaJoinningViewController``.
    var areaJoinningViewController: AreaJoinningViewControllable & AreaJoinningPresentable {
        shared { AreaJoinningViewController() }
    }
    
    
    var sessionIdentityServiceProxy: any VUProxy<FPSessionIdentityServicing> {
        dependency.sessionIdentityServiceProxy
    }
    
    
    var bootstraperService: FPBootstrapperServicing & VUMementoSnapshotable {
        dependency.bootstraperService
    }
    
    
    var bootstrapperServiceMementoAgent: FPBootstrapperServiceMementoAgent {
        dependency.bootstrapperServiceMementoAgent
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension AreaJoinningComponent: AreaJoinningCodeScanningDependency, AreaJoinningFormFillingDependency, AreaJoinningCTAShowingDependency {}



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
