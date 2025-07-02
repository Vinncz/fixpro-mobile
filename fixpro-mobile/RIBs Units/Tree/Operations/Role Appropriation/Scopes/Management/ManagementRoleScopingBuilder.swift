import Foundation
import RIBs



/// A set of properties that are required by `ManagementRoleScopingRIB` to function, 
/// supplied from the scope of its parent.
protocol ManagementRoleScopingDependency: Dependency {
    var authorizationContext: FPRoleContext { get }
    var networkingClient: FPNetworkingClient { get }
    var identityService: FPSessionIdentityServicing { get }
}



/// Concrete implementation of the ``ManagementRoleScopingDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``ManagementRoleScopingRouter``.
final class ManagementRoleScopingComponent: Component<ManagementRoleScopingDependency> {
    
    
    var authorizationContext: FPRoleContext {
        dependency.authorizationContext
    }
    
    
    var networkingClient: FPNetworkingClient {
        dependency.networkingClient
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension ManagementRoleScopingComponent: TicketNavigatorDependency, WorkCalendarDependency, AreaManagementNavigatorDependency, InboxNavigatorDependency, PreferencesDependency {
    
    
    var identityService: FPSessionIdentityServicing {
        dependency.identityService
    }
    
}



/// Contract adhered to by ``ManagementRoleScopingBuilder``, listing necessary actions to
/// construct a functional `ManagementRoleScopingRIB`.
protocol ManagementRoleScopingBuildable: Buildable {
    
    
    /// Constructs the `ManagementRoleScopingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: ManagementRoleScopingListener, triggerNotification: FPNotificationDigest?) -> ManagementRoleScopingRouting
    
}



/// The composer of `ManagementRoleScopingRIB`.
final class ManagementRoleScopingBuilder: Builder<ManagementRoleScopingDependency>, ManagementRoleScopingBuildable {
    
    
    /// Creates an instance of ``ManagementRoleScopingBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: ManagementRoleScopingDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `ManagementRoleScopingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: ManagementRoleScopingListener, triggerNotification: FPNotificationDigest?) -> ManagementRoleScopingRouting {
        let viewController = ManagementRoleScopingViewController()
        let component  = ManagementRoleScopingComponent(dependency: dependency)
        let interactor = ManagementRoleScopingInteractor(component: component, presenter: viewController, triggerNotification: triggerNotification)
            interactor.listener = listener
        
        return ManagementRoleScopingRouter(
            interactor: interactor, 
            viewController: viewController,
            ticketNavigatorBuilder: TicketNavigatorBuilder(dependency: component),
            workCalendarBuilder: WorkCalendarBuilder(dependency: component),
            areaManagementNavigatorBuilder: AreaManagementNavigatorBuilder(dependency: component),
            inboxNavigatorBuilder: InboxNavigatorBuilder(dependency: component),
            preferencesBuilder: PreferencesBuilder(dependency: component)
        )
    }
    
}
