import RIBs



/// A set of properties that are required by `MemberDetailRIB` to function, 
/// supplied from the scope of its parent.
protocol MemberDetailDependency: Dependency {
    
    
    var networkingClient: FPNetworkingClient { get }
    
}



/// Concrete implementation of the ``MemberDetailDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``MemberDetailRouter``.
final class MemberDetailComponent: Component<MemberDetailDependency> {
    
    
    var networkingClient: FPNetworkingClient {
        dependency.networkingClient
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension MemberDetailComponent {}



/// Contract adhered to by ``MemberDetailBuilder``, listing necessary actions to
/// construct a functional `MemberDetailRIB`.
protocol MemberDetailBuildable: Buildable {
    
    
    /// Constructs the `MemberDetailRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: MemberDetailListener, member: FPPerson) -> MemberDetailRouting
    
}



/// The composer of `MemberDetailRIB`.
final class MemberDetailBuilder: Builder<MemberDetailDependency>, MemberDetailBuildable {
    
    
    /// Creates an instance of ``MemberDetailBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: MemberDetailDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `MemberDetailRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: MemberDetailListener, member: FPPerson) -> MemberDetailRouting {
        let viewController = MemberDetailViewController()
        let component  = MemberDetailComponent(dependency: dependency)
        let interactor = MemberDetailInteractor(component: component, presenter: viewController, member: member)
        
        interactor.listener = listener
        
        return MemberDetailRouter(
            interactor: interactor, 
            viewController: viewController
        )
    }
    
}
