import RIBs



/// An empty set of properties. As the ancestral RIB, 
/// `SupportiveDocumentListRIB` does not require any dependencies from its parent scope.
protocol SupportiveDocumentListDependency: Dependency {}



/// Concrete implementation of the ``SupportiveDocumentListDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``SupportiveDocumentListRouter``.
final class SupportiveDocumentListComponent: Component<SupportiveDocumentListDependency> {
    
    
    /// Constructs a singleton instance of ``SupportiveDocumentListViewController``.
    var supportiveDocumentListViewController: SupportiveDocumentListViewControllable & SupportiveDocumentListPresentable {
        shared { SupportiveDocumentListViewController() }
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension SupportiveDocumentListComponent {}



/// Contract adhered to by ``SupportiveDocumentListBuilder``, listing necessary actions to
/// construct a functional `SupportiveDocumentListRIB`.
protocol SupportiveDocumentListBuildable: Buildable {
    
    
    /// Constructs the `SupportiveDocumentListRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: SupportiveDocumentListListener) -> SupportiveDocumentListRouting
    
}



/// The composer of `SupportiveDocumentListRIB`.
final class SupportiveDocumentListBuilder: Builder<SupportiveDocumentListDependency>, SupportiveDocumentListBuildable {
    
    
    /// Creates an instance of ``SupportiveDocumentListBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: SupportiveDocumentListDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `SupportiveDocumentListRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: SupportiveDocumentListListener) -> SupportiveDocumentListRouting {
        let component  = SupportiveDocumentListComponent(dependency: dependency)
        let interactor = SupportiveDocumentListInteractor(component: component)
            interactor.listener = listener
        
        return SupportiveDocumentListRouter(
            interactor: interactor, 
            viewController: component.supportiveDocumentListViewController
        )
    }
    
}
