import RIBs



/// A set of properties that are required by `TicketLogRIB` to function, 
/// supplied from the scope of its parent.
protocol TicketLogDependency: Dependency {}



/// Concrete implementation of the ``TicketLogDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``TicketLogRouter``.
final class TicketLogComponent: Component<TicketLogDependency> {}



/// Conformance to this RIB's children's `Dependency` protocols.
extension TicketLogComponent {}



/// Contract adhered to by ``TicketLogBuilder``, listing necessary actions to
/// construct a functional `TicketLogRIB`.
protocol TicketLogBuildable: Buildable {
    
    
    /// Constructs the `TicketLogRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: TicketLogListener, ticketLog: FPTicketLog) -> TicketLogRouting
    
}



/// The composer of `TicketLogRIB`.
final class TicketLogBuilder: Builder<TicketLogDependency>, TicketLogBuildable {
    
    
    /// Creates an instance of ``TicketLogBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: TicketLogDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `TicketLogRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: TicketLogListener, ticketLog: FPTicketLog) -> TicketLogRouting {
        let viewController = TicketLogViewController()
        let component  = TicketLogComponent(dependency: dependency)
        let interactor = TicketLogInteractor(component: component, presenter: viewController, ticketLog: ticketLog)
        
        interactor.listener = listener
        
        return TicketLogRouter(
            interactor: interactor, 
            viewController: viewController
        )
    }
    
}
