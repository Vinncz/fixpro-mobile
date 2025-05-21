import RIBs



/// A set of properties that are required by `AreaManagementApplicationReviewAndManagementRIB` to function, 
/// supplied from the scope of its parent.
protocol AreaManagementApplicationReviewAndManagementDependency: Dependency {}



/// Concrete implementation of the ``AreaManagementApplicationReviewAndManagementDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``AreaManagementApplicationReviewAndManagementRouter``.
final class AreaManagementApplicationReviewAndManagementComponent: Component<AreaManagementApplicationReviewAndManagementDependency> {}



/// Conformance to this RIB's children's `Dependency` protocols.
extension AreaManagementApplicationReviewAndManagementComponent {}



/// Contract adhered to by ``AreaManagementApplicationReviewAndManagementBuilder``, listing necessary actions to
/// construct a functional `AreaManagementApplicationReviewAndManagementRIB`.
protocol AreaManagementApplicationReviewAndManagementBuildable: Buildable {
    
    
    /// Constructs the `AreaManagementApplicationReviewAndManagementRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: AreaManagementApplicationReviewAndManagementListener) -> AreaManagementApplicationReviewAndManagementRouting
    
}



/// The composer of `AreaManagementApplicationReviewAndManagementRIB`.
final class AreaManagementApplicationReviewAndManagementBuilder: Builder<AreaManagementApplicationReviewAndManagementDependency>, AreaManagementApplicationReviewAndManagementBuildable {
    
    
    /// Creates an instance of ``AreaManagementApplicationReviewAndManagementBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: AreaManagementApplicationReviewAndManagementDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `AreaManagementApplicationReviewAndManagementRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: AreaManagementApplicationReviewAndManagementListener) -> AreaManagementApplicationReviewAndManagementRouting {
        let viewController = AreaManagementApplicationReviewAndManagementViewController()
        let component  = AreaManagementApplicationReviewAndManagementComponent(dependency: dependency)
        let interactor = AreaManagementApplicationReviewAndManagementInteractor(component: component, presenter: viewController)
        
        interactor.listener = listener
        
        return AreaManagementApplicationReviewAndManagementRouter(
            interactor: interactor, 
            viewController: viewController
        )
    }
    
}
