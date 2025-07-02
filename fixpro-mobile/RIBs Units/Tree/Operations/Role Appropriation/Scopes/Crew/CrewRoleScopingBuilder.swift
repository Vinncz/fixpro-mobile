import Foundation
import RIBs
import VinUtility



/// A set of properties that are required by `CrewRoleScopingRIB` to function, 
/// supplied from the scope of its parent.
protocol CrewRoleScopingDependency: Dependency {
    var authorizationContext: FPRoleContext { get }
    var locationBeacon: VULocationBeacon { get }
    var networkingClient: FPNetworkingClient { get }
    var identityService: FPSessionIdentityServicing { get }
}



/// Concrete implementation of the ``CrewRoleScopingDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``CrewRoleScopingRouter``.
final class CrewRoleScopingComponent: Component<CrewRoleScopingDependency> {
    
    
    var authorizationContext: FPRoleContext {
        dependency.authorizationContext
    }
    
    
    var locationBeacon: VULocationBeacon {
        dependency.locationBeacon
    }
    
    
    var networkingClient: FPNetworkingClient {
        dependency.networkingClient
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension CrewRoleScopingComponent: TicketNavigatorDependency, WorkCalendarDependency, NewTicketDependency, InboxNavigatorDependency, PreferencesDependency {
    
    
    var identityService: FPSessionIdentityServicing {
        dependency.identityService
    }
    
}



/// Contract adhered to by ``CrewRoleScopingBuilder``, listing necessary actions to
/// construct a functional `CrewRoleScopingRIB`.
protocol CrewRoleScopingBuildable: Buildable {
    
    
    /// Constructs the `CrewRoleScopingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: CrewRoleScopingListener, triggerNotification: FPNotificationDigest?) -> CrewRoleScopingRouting
    
}



/// The composer of `CrewRoleScopingRIB`.
final class CrewRoleScopingBuilder: Builder<CrewRoleScopingDependency>, CrewRoleScopingBuildable {
    
    
    /// Creates an instance of ``CrewRoleScopingBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: CrewRoleScopingDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `CrewRoleScopingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: CrewRoleScopingListener, triggerNotification: FPNotificationDigest?) -> CrewRoleScopingRouting {
        let viewController = CrewRoleScopingViewController()
        let component  = CrewRoleScopingComponent(dependency: dependency)
        let interactor = CrewRoleScopingInteractor(component: component, presenter: viewController, triggerNotification: triggerNotification)
        interactor.listener = listener
        
        return CrewRoleScopingRouter(
            interactor: interactor, 
            viewController: viewController,
            ticketNavigatorBuilder: TicketNavigatorBuilder(dependency: component),
            workCalendarBuilder: WorkCalendarBuilder(dependency: component),
            newTicketBuilder: NewTicketBuilder(dependency: component),
            inboxNavigatorBuilder: InboxNavigatorBuilder(dependency: component),
            preferencesBuilder: PreferencesBuilder(dependency: component)
        )
    }
    
}
