import RIBs


/// Collection of types whose instances are necessary for `RoleAppropriationRIB` to function.
/// 
/// This protocol may be used externally of `RoleAppropriationRIB`.
/// 
/// When you intend for `RoleAppropriationRIB` to bear descendant(s), 
/// you **MUST** conform either ``RoleAppropriationDependency`` 
/// or ``RoleAppropriationComponent`` to their descendant(s)' `Dependency` protocol.
/// 
/// You'd only need to conform to your immidiate children's `Dependency` protocol--NOT the entire hierarchy.
/// 
/// When seen in context, this condition resembles train that passes through stations--though they're not stopping there.
/// 
/// By default, ``RoleAppropriationBuilder`` uses a concrete implementation of
/// this protocol--usually the ``RoleAppropriationComponent``.
protocol RoleAppropriationDependency: Dependency {
    /// The view which `RoleAppropriationRIB` will be able to manipulate.
    var roleAppropriationViewController: RoleAppropriationViewControllable { get }
}


/// Concrete implementation of ``RoleAppropriationDependency``.
/// 
/// An instance of `Component` is created by a `Builder`, to resolve instances for each attribute declared in its `Dependency`.
/// 
/// In this case, the ``RoleAppropriationBuilder`` is responsible to make an instance of ``RoleAppropriationComponent``
/// which then populates the properties of ``RoleAppropriationDependency``.
final class RoleAppropriationComponent: Component<RoleAppropriationDependency> {
    // Fileprivate attribute marks dependencies to be provided by self--and not some outside source.
    fileprivate var roleAppropriationViewController: RoleAppropriationViewControllable {
        return dependency.roleAppropriationViewController
    }
}


/// Collection of methods who defines what it takes to construct `RoleAppropriationRIB`.
///
/// By conforming a `Builder` to this, you declare that it can create and initialize 
/// the `RoleAppropriationRIB` if given the required dependencies.
protocol RoleAppropriationBuildable: Buildable {
    /// Constructs and initializes the `RoleAppropriationRIB`.
    /// 
    /// @param withListener: The parent RIB's `Interactor`.
    func build (withListener listener: RoleAppropriationListener) -> RoleAppropriationRouting
}


/// Constructs and assembles the `RoleAppropriationRIB`.
///
/// The `Builder` class are responsible for creating and assembling all the necessary parts of a RIB. 
/// This covers from resolving dependencies, to using them in instantiating the `Interactor`, `Router`, and `ViewController`.
/// 
/// The ``RoleAppropriationBuilder`` should be created inside the parent RIB's `Builder`, then invoked by the parent's `Router`.
/// 
/// Continuing this trend, this `Builder` should also supply its children with the builder that constructs its grandchildren.
final class RoleAppropriationBuilder: Builder<RoleAppropriationDependency>, RoleAppropriationBuildable {

    override init (dependency: RoleAppropriationDependency) {
        super.init(dependency: dependency)
    }

    func build (withListener listener: RoleAppropriationListener) -> RoleAppropriationRouting {
        let component  = RoleAppropriationComponent(dependency: dependency)
        let interactor = RoleAppropriationInteractor()
            interactor.listener = listener
        
        let msd: MemberScopeDependency = {
            class MSD: MemberScopeDependency {}
            return MSD()
        }()
        let mcsd: MaintenanceCrewScopeDependency = {
            class MCsd: MaintenanceCrewScopeDependency {}
            return MCsd()
        }()
        let mgsd: ManagementTeamScopeDependency = {
            class MGsd: ManagementTeamScopeDependency {}
            return MGsd()
        }()
        
        return RoleAppropriationRouter (
            interactor: interactor, 
            viewController: component.roleAppropriationViewController,
            memberScopeBuilder: MemberScopeBuilder(dependency: msd),
            maintenanceCrewScopeBuilder: MaintenanceCrewScopeBuilder(dependency: mcsd),
            managementScopeBuilder: ManagementTeamScopeBuilder(dependency: mgsd)
        )
    }
    
}
