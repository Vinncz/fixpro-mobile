import RIBs
import VinUtility



/// An empty set of properties. As the ancestral RIB, 
/// `AreaJoinningFormFillingRIB` does not require any dependencies from its parent scope.
protocol AreaJoinningFormFillingDependency: Dependency {
    var onboardingService: FPOnboardingServicing { get }
}



/// Concrete implementation of the ``AreaJoinningFormFillingDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``AreaJoinningFormFillingRouter``.
final class AreaJoinningFormFillingComponent: Component<AreaJoinningFormFillingDependency> {
    
    
    /// Constructs a singleton instance of ``AreaJoinningFormFillingViewController``.
    var areaJoinningFormFillingViewController: AreaJoinningFormFillingViewControllable & AreaJoinningFormFillingPresentable {
        shared { AreaJoinningFormFillingViewController() }
    }
    
    
    /// The object that is integral to complete the onboarding process.
    var onboardingService: FPOnboardingServicing {
        dependency.onboardingService
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension AreaJoinningFormFillingComponent {}



/// Contract adhered to by ``AreaJoinningFormFillingBuilder``, listing necessary actions to
/// construct a functional `AreaJoinningFormFillingRIB`.
protocol AreaJoinningFormFillingBuildable: Buildable {
    
    
    /// Constructs the `AreaJoinningFormFillingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: AreaJoinningFormFillingListener, fields: [String]) -> AreaJoinningFormFillingRouting
    
}



/// The composer of `AreaJoinningFormFillingRIB`.
final class AreaJoinningFormFillingBuilder: Builder<AreaJoinningFormFillingDependency>, AreaJoinningFormFillingBuildable {
    
    
    /// Creates an instance of ``AreaJoinningFormFillingBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: AreaJoinningFormFillingDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `AreaJoinningFormFillingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: AreaJoinningFormFillingListener, fields: [String]) -> AreaJoinningFormFillingRouting {
        let component  = AreaJoinningFormFillingComponent(dependency: dependency)
        let interactor = AreaJoinningFormFillingInteractor(component: component, fields: fields)
            interactor.listener = listener
        
        return AreaJoinningFormFillingRouter(
            interactor: interactor, 
            viewController: component.areaJoinningFormFillingViewController
        )
    }
    
}
