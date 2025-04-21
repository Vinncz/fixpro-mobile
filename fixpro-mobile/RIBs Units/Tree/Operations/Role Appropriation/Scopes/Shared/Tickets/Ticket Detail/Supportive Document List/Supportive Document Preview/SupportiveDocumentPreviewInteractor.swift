import RIBs
import RxSwift



/// Contract adhered to by ``SupportiveDocumentPreviewRouter``, listing the attributes and/or actions 
/// that ``SupportiveDocumentPreviewInteractor`` is allowed to access or invoke.
protocol SupportiveDocumentPreviewRouting: ViewableRouting {}



/// Contract adhered to by ``SupportiveDocumentPreviewViewController``, listing the attributes and/or actions
/// that ``SupportiveDocumentPreviewInteractor`` is allowed to access or invoke.
protocol SupportiveDocumentPreviewPresentable: Presentable {
    
    
    /// Reference to ``SupportiveDocumentPreviewInteractor``.
    var presentableListener: SupportiveDocumentPreviewPresentableListener? { get set }
    
}



/// Contract adhered to by the Interactor of `SupportiveDocumentPreviewRIB`'s parent, listing the attributes and/or actions
/// that ``SupportiveDocumentPreviewInteractor`` is allowed to access or invoke.
protocol SupportiveDocumentPreviewListener: AnyObject {}



/// The functionality centre of `SupportiveDocumentPreviewRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class SupportiveDocumentPreviewInteractor: PresentableInteractor<SupportiveDocumentPreviewPresentable>, SupportiveDocumentPreviewInteractable {
    
    
    /// Reference to ``SupportiveDocumentPreviewRouter``.
    weak var router: SupportiveDocumentPreviewRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: SupportiveDocumentPreviewListener?
    
    
    /// Reference to the component of this RIB.
    var component: SupportiveDocumentPreviewComponent
    
    
    /// Constructs an instance of ``SupportiveDocumentPreviewInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: SupportiveDocumentPreviewComponent) {
        self.component = component
        let presenter = component.supportiveDocumentPreviewViewController
        
        super.init(presenter: presenter)
        
        presenter.presentableListener = self
    }
    
    
    /// Customization point that is invoked after self becomes active.
    override func didBecomeActive() {
        super.didBecomeActive()
    }
    
    
    /// Customization point that is invoked before self is detached.
    override func willResignActive() {
        super.willResignActive()
    }
    
}



/// Conformance to the ``SupportiveDocumentPreviewPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``SupportiveDocumentPreviewViewController``
extension SupportiveDocumentPreviewInteractor: SupportiveDocumentPreviewPresentableListener {}
