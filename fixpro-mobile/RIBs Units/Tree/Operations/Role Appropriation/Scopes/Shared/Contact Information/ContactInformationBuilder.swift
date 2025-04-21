import RIBs



/// An empty set of properties. As the ancestral RIB, 
/// `ContactInformationRIB` does not require any dependencies from its parent scope.
protocol ContactInformationDependency: Dependency {}



/// Concrete implementation of the ``ContactInformationDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``ContactInformationRouter``.
final class ContactInformationComponent: Component<ContactInformationDependency> {
    
    
    /// Constructs a singleton instance of ``ContactInformationViewController``.
    var contactInformationViewController: ContactInformationViewControllable & ContactInformationPresentable {
        shared { ContactInformationViewController() }
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension ContactInformationComponent {}



/// Contract adhered to by ``ContactInformationBuilder``, listing necessary actions to
/// construct a functional `ContactInformationRIB`.
protocol ContactInformationBuildable: Buildable {
    
    
    /// Constructs the `ContactInformationRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: ContactInformationListener) -> ContactInformationRouting
    
}



/// The composer of `ContactInformationRIB`.
final class ContactInformationBuilder: Builder<ContactInformationDependency>, ContactInformationBuildable {
    
    
    /// Creates an instance of ``ContactInformationBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: ContactInformationDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `ContactInformationRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: ContactInformationListener) -> ContactInformationRouting {
        let component  = ContactInformationComponent(dependency: dependency)
        let interactor = ContactInformationInteractor(component: component)
            interactor.listener = listener
        
        return ContactInformationRouter(
            interactor: interactor, 
            viewController: component.contactInformationViewController
        )
    }
    
}
