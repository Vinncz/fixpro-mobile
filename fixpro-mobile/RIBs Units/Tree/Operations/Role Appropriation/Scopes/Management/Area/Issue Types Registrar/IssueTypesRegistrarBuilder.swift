import RIBs



/// A set of properties that are required by `IssueTypesRegistrarRIB` to function, 
/// supplied from the scope of its parent.
protocol IssueTypesRegistrarDependency: Dependency {
    
    
    var networkingClient: FPNetworkingClient { get }
    
}



/// Concrete implementation of the ``IssueTypesRegistrarDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``IssueTypesRegistrarRouter``.
final class IssueTypesRegistrarComponent: Component<IssueTypesRegistrarDependency> {
    
    
    var networkingClient: FPNetworkingClient {
        dependency.networkingClient
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension IssueTypesRegistrarComponent {}



/// Contract adhered to by ``IssueTypesRegistrarBuilder``, listing necessary actions to
/// construct a functional `IssueTypesRegistrarRIB`.
protocol IssueTypesRegistrarBuildable: Buildable {
    
    
    /// Constructs the `IssueTypesRegistrarRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: IssueTypesRegistrarListener) -> IssueTypesRegistrarRouting
    
}



/// The composer of `IssueTypesRegistrarRIB`.
final class IssueTypesRegistrarBuilder: Builder<IssueTypesRegistrarDependency>, IssueTypesRegistrarBuildable {
    
    
    /// Creates an instance of ``IssueTypesRegistrarBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: IssueTypesRegistrarDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `IssueTypesRegistrarRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: IssueTypesRegistrarListener) -> IssueTypesRegistrarRouting {
        let viewController = IssueTypesRegistrarViewController()
        let component  = IssueTypesRegistrarComponent(dependency: dependency)
        let interactor = IssueTypesRegistrarInteractor(component: component, presenter: viewController)
        
        interactor.listener = listener
        
        return IssueTypesRegistrarRouter(
            interactor: interactor, 
            viewController: viewController
        )
    }
    
}
