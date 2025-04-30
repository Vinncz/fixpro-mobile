import RIBs



/// An empty set of properties. As the ancestral RIB, 
/// `WorkCalendarRIB` does not require any dependencies from its parent scope.
protocol WorkCalendarDependency: Dependency {
    var authorizationContext: FPRoleContext { get }
}



/// Concrete implementation of the ``WorkCalendarDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``WorkCalendarRouter``.
final class WorkCalendarComponent: Component<WorkCalendarDependency> {
    
    
    /// Constructs a singleton instance of ``WorkCalendarViewController``.
    var workCalendarViewController: WorkCalendarViewControllable & WorkCalendarPresentable {
        shared { WorkCalendarViewController() }
    }
    
    
    var authorizationContext: FPRoleContext {
        dependency.authorizationContext
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension WorkCalendarComponent {}



/// Contract adhered to by ``WorkCalendarBuilder``, listing necessary actions to
/// construct a functional `WorkCalendarRIB`.
protocol WorkCalendarBuildable: Buildable {
    
    
    /// Constructs the `WorkCalendarRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: WorkCalendarListener) -> WorkCalendarRouting
    
}



/// The composer of `WorkCalendarRIB`.
final class WorkCalendarBuilder: Builder<WorkCalendarDependency>, WorkCalendarBuildable {
    
    
    /// Creates an instance of ``WorkCalendarBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: WorkCalendarDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `WorkCalendarRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: WorkCalendarListener) -> WorkCalendarRouting {
        let component  = WorkCalendarComponent(dependency: dependency)
        let interactor = WorkCalendarInteractor(component: component)
            interactor.listener = listener
        
        return WorkCalendarRouter(
            interactor: interactor, 
            viewController: component.workCalendarViewController
        )
    }
    
}
