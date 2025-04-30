import Foundation
import RIBs



/// A set of properties that are required by `TicketReportRIB` to function, 
/// supplied from the scope of its parent.
protocol TicketReportDependency: Dependency {}



/// Concrete implementation of the ``TicketReportDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``TicketReportRouter``.
final class TicketReportComponent: Component<TicketReportDependency> {}



/// Conformance to this RIB's children's `Dependency` protocols.
extension TicketReportComponent {}



/// Contract adhered to by ``TicketReportBuilder``, listing necessary actions to
/// construct a functional `TicketReportRIB`.
protocol TicketReportBuildable: Buildable {
    
    
    /// Constructs the `TicketReportRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: TicketReportListener, urlToReport: URL) -> TicketReportRouting
    
}



/// The composer of `TicketReportRIB`.
final class TicketReportBuilder: Builder<TicketReportDependency>, TicketReportBuildable {
    
    
    /// Creates an instance of ``TicketReportBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: TicketReportDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `TicketReportRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: TicketReportListener, urlToReport: URL) -> TicketReportRouting {
        let viewController = TicketReportViewController()
        let component  = TicketReportComponent(dependency: dependency)
        let interactor = TicketReportInteractor(component: component, presenter: viewController, urlToReport: urlToReport)
        
        interactor.listener = listener
        
        return TicketReportRouter(
            interactor: interactor, 
            viewController: viewController
        )
    }
    
}
