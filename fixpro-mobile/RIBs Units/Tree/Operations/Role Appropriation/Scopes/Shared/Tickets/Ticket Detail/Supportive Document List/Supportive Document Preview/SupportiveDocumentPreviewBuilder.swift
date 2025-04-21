import RIBs



/// A set of properties that are required by `SupportiveDocumentPreviewRIB` to function, 
/// supplied from the scope of its parent.
protocol SupportiveDocumentPreviewDependency: Dependency {}



/// Concrete implementation of the ``SupportiveDocumentPreviewDependency`` protocol. 
/// Provides dependencies needed by all RIBs that will ever attach themselves to ``SupportiveDocumentPreviewRouter``.
final class SupportiveDocumentPreviewComponent: Component<SupportiveDocumentPreviewDependency> {
    
    
    /// Constructs a singleton instance of ``SupportiveDocumentPreviewViewController``.
    var supportiveDocumentPreviewViewController: SupportiveDocumentPreviewViewControllable & SupportiveDocumentPreviewPresentable {
        shared { SupportiveDocumentPreviewViewController() }
    }
    
}



/// Conformance to this RIB's children's `Dependency` protocols.
extension SupportiveDocumentPreviewComponent {}



/// Contract adhered to by ``SupportiveDocumentPreviewBuilder``, listing necessary actions to
/// construct a functional `SupportiveDocumentPreviewRIB`.
protocol SupportiveDocumentPreviewBuildable: Buildable {
    
    
    /// Constructs the `SupportiveDocumentPreviewRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: SupportiveDocumentPreviewListener) -> SupportiveDocumentPreviewRouting
    
}



/// The composer of `SupportiveDocumentPreviewRIB`.
final class SupportiveDocumentPreviewBuilder: Builder<SupportiveDocumentPreviewDependency>, SupportiveDocumentPreviewBuildable {
    
    
    /// Creates an instance of ``SupportiveDocumentPreviewBuilder``.
    /// - Parameter dependency: Instance of other RIB's `Component` that conforms to this RIB's `Dependency` protocol.
    override init(dependency: SupportiveDocumentPreviewDependency) {
        super.init(dependency: dependency)
    }
    
    
    /// Constructs the `SupportiveDocumentPreviewRIB`.
    /// - Parameter listener: The `Interactor` of this RIB's parent.
    func build(withListener listener: SupportiveDocumentPreviewListener) -> SupportiveDocumentPreviewRouting {
        let component  = SupportiveDocumentPreviewComponent(dependency: dependency)
        let interactor = SupportiveDocumentPreviewInteractor(component: component)
            interactor.listener = listener
        
        return SupportiveDocumentPreviewRouter(
            interactor: interactor, 
            viewController: component.supportiveDocumentPreviewViewController
        )
    }
    
}
