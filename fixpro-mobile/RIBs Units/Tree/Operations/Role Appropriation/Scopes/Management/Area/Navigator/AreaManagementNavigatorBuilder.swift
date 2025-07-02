import RIBs



/// A set of properties that are required by `AreaManagementNavigatorRIB` to function, 
/// supplied from the scope of its parent.
protocol AreaManagementNavigatorDependency: Dependency {
    var authorizationContext: FPRoleContext { get }
    var networkingClient: FPNetworkingClient { get }
    var identityService: FPSessionIdentityServicing { get }
}



/// Concrete implementation of the ``AreaManagementNavigatorDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``AreaManagementNavigatorRouter``.
final class AreaManagementNavigatorComponent: Component<AreaManagementNavigatorDependency> {}



/// Conformance to this RIB's children's `Dependency` protocols.
extension AreaManagementNavigatorComponent: AreaManagementDependency, 
                                            ManageMembershipsDependency,
                                                ApplicantDetailDependency,
                                                MemberDetailDependency,
                                            IssueTypesRegistrarDependency, 
                                            ManageSLADependency, 
                                            StatisticsAndReportsDependency 
{
    
    
    var authorizationContext: FPRoleContext {
        dependency.authorizationContext
    }
    
    
    var networkingClient: FPNetworkingClient {
        dependency.networkingClient
    }
    
    
    var identityService: FPSessionIdentityServicing {
        dependency.identityService
    }
    
}



/// Contract adhered to by ``AreaManagementNavigatorBuilder``, listing necessary actions to
/// construct a functional `AreaManagementNavigatorRIB`.
protocol AreaManagementNavigatorBuildable: Buildable {
    
    
    /// Constructs the `AreaManagementNavigatorRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: AreaManagementNavigatorListener) -> AreaManagementNavigatorRouting
    
}



/// The composer of `AreaManagementNavigatorRIB`.
final class AreaManagementNavigatorBuilder: Builder<AreaManagementNavigatorDependency>, AreaManagementNavigatorBuildable {
    
    
    /// Creates an instance of ``AreaManagementNavigatorBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: AreaManagementNavigatorDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `AreaManagementNavigatorRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: AreaManagementNavigatorListener) -> AreaManagementNavigatorRouting {
        let viewController = AreaManagementNavigatorNavigationController()
        let component  = AreaManagementNavigatorComponent(dependency: dependency)
        let interactor = AreaManagementNavigatorInteractor(component: component, presenter: viewController)
        
        interactor.listener = listener
        
        return AreaManagementNavigatorRouter(
            interactor: interactor, 
            viewController: viewController,
            areaManagementBuilder: AreaManagementBuilder(dependency: component),
            manageMembershipsBuilder: ManageMembershipsBuilder(dependency: component),
            applicantDetailBuilder: ApplicantDetailBuilder(dependency: component),
            memberDetailBuilder: MemberDetailBuilder(dependency: component),
            issueTypesRegistrarBuilder: IssueTypesRegistrarBuilder(dependency: component),
            manageSLABuilder: ManageSLABuilder(dependency: component),
            statisticsAndReportsBuilder: StatisticsAndReportsBuilder(dependency: component)
        )
    }
    
}
