import Foundation
import RIBs
import VinUtility



/// A set of properties that are required by `MemberRoleScopingRIB` to function, 
/// supplied from the scope of its parent.
protocol MemberRoleScopingDependency: Dependency {
    var authorizationContext: FPRoleContext { get }
    var locationBeacon: VULocationBeacon { get }
    var networkingClient: FPNetworkingClient { get }
}



/// Concrete implementation of the ``MemberRoleScopingDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``MemberRoleScopingRouter``.
final class MemberRoleScopingComponent: Component<MemberRoleScopingDependency> {
    
    
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
extension MemberRoleScopingComponent: TicketNavigatorDependency, NewTicketDependency, InboxNavigatorDependency, PreferencesDependency {}



/// Contract adhered to by ``MemberRoleScopingBuilder``, listing necessary actions to
/// construct a functional `MemberRoleScopingRIB`.
protocol MemberRoleScopingBuildable: Buildable {
    
    
    /// Constructs the `MemberRoleScopingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: MemberRoleScopingListener, triggerNotification: FPNotificationDigest?) -> MemberRoleScopingRouting
    
}



/// The composer of `MemberRoleScopingRIB`.
final class MemberRoleScopingBuilder: Builder<MemberRoleScopingDependency>, MemberRoleScopingBuildable {
    
    
    /// Creates an instance of ``MemberRoleScopingBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: MemberRoleScopingDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `MemberRoleScopingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: MemberRoleScopingListener, triggerNotification: FPNotificationDigest?) -> MemberRoleScopingRouting {
        let viewController = MemberRoleScopingViewController()
        let component  = MemberRoleScopingComponent(dependency: dependency)
        let interactor = MemberRoleScopingInteractor(component: component, presenter: viewController, triggerNotification: triggerNotification)
        
        interactor.listener = listener
        
        return MemberRoleScopingRouter(
            interactor: interactor, 
            viewController: viewController,
            ticketNavigatorBuilder: TicketNavigatorBuilder(dependency: component),
            newTicketBuilder: NewTicketBuilder(dependency: component),
            inboxNavigatorBuilder: InboxNavigatorBuilder(dependency: component),
            preferencesBuilder: PreferencesBuilder(dependency: component)
        )
    }
    
}
