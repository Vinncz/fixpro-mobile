import RIBs
import VinUtility



/// An empty set of properties. As the ancestral RIB, 
/// `AreaJoinningCodeScanningRIB` does not require any dependencies from its parent scope.
protocol AreaJoinningCodeScanningDependency: Dependency {
    var onboardingServiceProxy: any VUProxy<FPOnboardingServicing> { get }
}



/// Concrete implementation of the ``AreaJoinningCodeScanningDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``AreaJoinningCodeScanningRouter``.
final class AreaJoinningCodeScanningComponent: Component<AreaJoinningCodeScanningDependency> {
    
    
    /// Constructs a singleton instance of ``AreaJoinningCodeScanningViewController``.
    var areaJoinningCodeScanningViewController: AreaJoinningCodeScanningViewControllable & AreaJoinningCodeScanningPresentable {
        shared { AreaJoinningCodeScanningViewController() }
    }
    
    
    /// The proxy to the object that is integral to complete the onboarding process.
    var onboardingServiceProxy: any VUProxy<FPOnboardingServicing> {
        dependency.onboardingServiceProxy
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension AreaJoinningCodeScanningComponent {}



/// Contract adhered to by ``AreaJoinningCodeScanningBuilder``, listing necessary actions to
/// construct a functional `AreaJoinningCodeScanningRIB`.
protocol AreaJoinningCodeScanningBuildable: Buildable {
    
    
    /// Constructs the `AreaJoinningCodeScanningRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: AreaJoinningCodeScanningListener) -> AreaJoinningCodeScanningRouting
    
}



/// The composer of `AreaJoinningCodeScanningRIB`.
final class AreaJoinningCodeScanningBuilder: Builder<AreaJoinningCodeScanningDependency>, AreaJoinningCodeScanningBuildable {
    
    
    /// Creates an instance of ``AreaJoinningCodeScanningBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: AreaJoinningCodeScanningDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `AreaJoinningCodeScanningRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: AreaJoinningCodeScanningListener) -> AreaJoinningCodeScanningRouting {
        let component  = AreaJoinningCodeScanningComponent(dependency: dependency)
        let interactor = AreaJoinningCodeScanningInteractor(component: component)
            interactor.listener = listener
        
        return AreaJoinningCodeScanningRouter(
            interactor: interactor, 
            viewController: component.areaJoinningCodeScanningViewController
        )
    }
    
}
