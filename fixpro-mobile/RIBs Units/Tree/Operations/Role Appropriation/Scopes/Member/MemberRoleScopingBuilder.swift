import Foundation
import RIBs



/// A set of properties that are required by `MemberRoleScopingRIB` to function, 
/// supplied from the scope of its parent.
protocol MemberRoleScopingDependency: Dependency {}



/// Concrete implementation of the ``MemberRoleScopingDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``MemberRoleScopingRouter``.
final class MemberRoleScopingComponent: Component<MemberRoleScopingDependency> {
    
    
    /// Constructs a singleton instance of ``MemberRoleScopingViewController``.
    var memberRoleScopingViewController: MemberRoleScopingViewControllable & MemberRoleScopingPresentable {
        shared { MemberRoleScopingViewController() }
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension MemberRoleScopingComponent: TicketListsDependency, NewTicketDependency, InboxDependency, PreferencesDependency {}



/// Contract adhered to by ``MemberRoleScopingBuilder``, listing necessary actions to
/// construct a functional `MemberRoleScopingRIB`.
protocol MemberRoleScopingBuildable: Buildable {
    
    
    /// Constructs the `MemberRoleScopingRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: MemberRoleScopingListener) -> MemberRoleScopingRouting
    
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
    func build(withListener listener: MemberRoleScopingListener) -> MemberRoleScopingRouting {
        let component  = MemberRoleScopingComponent(dependency: dependency)
        let interactor = MemberRoleScopingInteractor(component: component)
            interactor.listener = listener
        
        return MemberRoleScopingRouter(
            interactor: interactor, 
            viewController: component.memberRoleScopingViewController,
            ticketListBuilder: TicketListsBuilder(dependency: component),
            newTicketBuilder: NewTicketBuilder(dependency: component),
            inboxBuilder: InboxBuilder(dependency: component),
            preferencesBuilder: PreferencesBuilder(dependency: component)
        )
    }
    
}
