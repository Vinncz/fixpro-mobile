import RIBs



/// A set of properties that are required by `StatisticsAndReportsRIB` to function, 
/// supplied from the scope of its parent.
protocol StatisticsAndReportsDependency: Dependency {
    
    
    var networkingClient: FPNetworkingClient { get }
    
    
    var identityService: FPSessionIdentityServicing { get }
    
}



/// Concrete implementation of the ``StatisticsAndReportsDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``StatisticsAndReportsRouter``.
final class StatisticsAndReportsComponent: Component<StatisticsAndReportsDependency> {
    
    
    var networkingClient: FPNetworkingClient { dependency.networkingClient }
    
    
    var identityService: FPSessionIdentityServicing {
        dependency.identityService
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension StatisticsAndReportsComponent {}



/// Contract adhered to by ``StatisticsAndReportsBuilder``, listing necessary actions to
/// construct a functional `StatisticsAndReportsRIB`.
protocol StatisticsAndReportsBuildable: Buildable {
    
    
    /// Constructs the `StatisticsAndReportsRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: StatisticsAndReportsListener) -> StatisticsAndReportsRouting
    
}



/// The composer of `StatisticsAndReportsRIB`.
final class StatisticsAndReportsBuilder: Builder<StatisticsAndReportsDependency>, StatisticsAndReportsBuildable {
    
    
    /// Creates an instance of ``StatisticsAndReportsBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: StatisticsAndReportsDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `StatisticsAndReportsRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: StatisticsAndReportsListener) -> StatisticsAndReportsRouting {
        let viewController = StatisticsAndReportsViewController()
        let component  = StatisticsAndReportsComponent(dependency: dependency)
        let interactor = StatisticsAndReportsInteractor(component: component, presenter: viewController)
        
        interactor.listener = listener
        
        return StatisticsAndReportsRouter(
            interactor: interactor, 
            viewController: viewController
        )
    }
    
}
