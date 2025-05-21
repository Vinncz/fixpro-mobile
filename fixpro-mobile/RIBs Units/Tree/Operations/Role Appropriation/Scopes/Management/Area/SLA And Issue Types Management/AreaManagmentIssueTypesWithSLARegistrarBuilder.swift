import RIBs



/// A set of properties that are required by `AreaManagmentIssueTypesWithSLARegistrarRIB` to function, 
/// supplied from the scope of its parent.
protocol AreaManagmentIssueTypesWithSLARegistrarDependency: Dependency {}



/// Concrete implementation of the ``AreaManagmentIssueTypesWithSLARegistrarDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``AreaManagmentIssueTypesWithSLARegistrarRouter``.
final class AreaManagmentIssueTypesWithSLARegistrarComponent: Component<AreaManagmentIssueTypesWithSLARegistrarDependency> {}



/// Conformance to this RIB's children's `Dependency` protocols.
extension AreaManagmentIssueTypesWithSLARegistrarComponent {}



/// Contract adhered to by ``AreaManagmentIssueTypesWithSLARegistrarBuilder``, listing necessary actions to
/// construct a functional `AreaManagmentIssueTypesWithSLARegistrarRIB`.
protocol AreaManagmentIssueTypesWithSLARegistrarBuildable: Buildable {
    
    
    /// Constructs the `AreaManagmentIssueTypesWithSLARegistrarRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: AreaManagmentIssueTypesWithSLARegistrarListener) -> AreaManagmentIssueTypesWithSLARegistrarRouting
    
}



/// The composer of `AreaManagmentIssueTypesWithSLARegistrarRIB`.
final class AreaManagmentIssueTypesWithSLARegistrarBuilder: Builder<AreaManagmentIssueTypesWithSLARegistrarDependency>, AreaManagmentIssueTypesWithSLARegistrarBuildable {
    
    
    /// Creates an instance of ``AreaManagmentIssueTypesWithSLARegistrarBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: AreaManagmentIssueTypesWithSLARegistrarDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `AreaManagmentIssueTypesWithSLARegistrarRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: AreaManagmentIssueTypesWithSLARegistrarListener) -> AreaManagmentIssueTypesWithSLARegistrarRouting {
        let viewController = AreaManagmentIssueTypesWithSLARegistrarViewController()
        let component  = AreaManagmentIssueTypesWithSLARegistrarComponent(dependency: dependency)
        let interactor = AreaManagmentIssueTypesWithSLARegistrarInteractor(component: component, presenter: viewController)
        
        interactor.listener = listener
        
        return AreaManagmentIssueTypesWithSLARegistrarRouter(
            interactor: interactor, 
            viewController: viewController
        )
    }
    
}
