import RIBs



/// A set of properties that are required by `AreaManagementStatisticsRIB` to function, 
/// supplied from the scope of its parent.
protocol AreaManagementStatisticsDependency: Dependency {}



/// Concrete implementation of the ``AreaManagementStatisticsDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``AreaManagementStatisticsRouter``.
final class AreaManagementStatisticsComponent: Component<AreaManagementStatisticsDependency> {}



/// Conformance to this RIB's children's `Dependency` protocols.
extension AreaManagementStatisticsComponent {}



/// Contract adhered to by ``AreaManagementStatisticsBuilder``, listing necessary actions to
/// construct a functional `AreaManagementStatisticsRIB`.
protocol AreaManagementStatisticsBuildable: Buildable {
    
    
    /// Constructs the `AreaManagementStatisticsRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: AreaManagementStatisticsListener) -> AreaManagementStatisticsRouting
    
}



/// The composer of `AreaManagementStatisticsRIB`.
final class AreaManagementStatisticsBuilder: Builder<AreaManagementStatisticsDependency>, AreaManagementStatisticsBuildable {
    
    
    /// Creates an instance of ``AreaManagementStatisticsBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: AreaManagementStatisticsDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `AreaManagementStatisticsRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: AreaManagementStatisticsListener) -> AreaManagementStatisticsRouting {
        let viewController = AreaManagementStatisticsViewController()
        let component  = AreaManagementStatisticsComponent(dependency: dependency)
        let interactor = AreaManagementStatisticsInteractor(component: component, presenter: viewController)
        
        interactor.listener = listener
        
        return AreaManagementStatisticsRouter(
            interactor: interactor, 
            viewController: viewController
        )
    }
    
}
