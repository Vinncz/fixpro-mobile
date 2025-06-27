import RIBs



/// A set of properties that are required by `ApplicantDetailRIB` to function, 
/// supplied from the scope of its parent.
protocol ApplicantDetailDependency: Dependency {
    
    
    var networkingClient: FPNetworkingClient { get }
    
}



/// Concrete implementation of the ``ApplicantDetailDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``ApplicantDetailRouter``.
final class ApplicantDetailComponent: Component<ApplicantDetailDependency> {
    
    
    var networkingClient: FPNetworkingClient {
        dependency.networkingClient
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension ApplicantDetailComponent {}



/// Contract adhered to by ``ApplicantDetailBuilder``, listing necessary actions to
/// construct a functional `ApplicantDetailRIB`.
protocol ApplicantDetailBuildable: Buildable {
    
    
    /// Constructs the `ApplicantDetailRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: ApplicantDetailListener, applicant: FPEntryApplication) -> ApplicantDetailRouting
    
}



/// The composer of `ApplicantDetailRIB`.
final class ApplicantDetailBuilder: Builder<ApplicantDetailDependency>, ApplicantDetailBuildable {
    
    
    /// Creates an instance of ``ApplicantDetailBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: ApplicantDetailDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `ApplicantDetailRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: ApplicantDetailListener, applicant: FPEntryApplication) -> ApplicantDetailRouting {
        let viewController = ApplicantDetailViewController()
        let component  = ApplicantDetailComponent(dependency: dependency)
        let interactor = ApplicantDetailInteractor(component: component, presenter: viewController, applicant: applicant)
        
        interactor.listener = listener
        
        return ApplicantDetailRouter(
            interactor: interactor, 
            viewController: viewController
        )
    }
    
}
