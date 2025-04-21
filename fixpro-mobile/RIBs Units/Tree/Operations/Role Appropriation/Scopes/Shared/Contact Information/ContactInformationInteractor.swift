import RIBs
import RxSwift



/// Contract adhered to by ``ContactInformationRouter``, listing the attributes and/or actions 
/// that ``ContactInformationInteractor`` is allowed to access or invoke.
protocol ContactInformationRouting: ViewableRouting {}



/// Contract adhered to by ``ContactInformationViewController``, listing the attributes and/or actions
/// that ``ContactInformationInteractor`` is allowed to access or invoke.
protocol ContactInformationPresentable: Presentable {
    
    
    /// Reference to ``ContactInformationInteractor``.
    var presentableListener: ContactInformationPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: ContactInformationSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `ContactInformationRIB`'s parent, listing the attributes and/or actions
/// that ``ContactInformationInteractor`` is allowed to access or invoke.
protocol ContactInformationListener: AnyObject {}



/// The functionality centre of `ContactInformationRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class ContactInformationInteractor: PresentableInteractor<ContactInformationPresentable>, ContactInformationInteractable {
    
    
    /// Reference to ``ContactInformationRouter``.
    weak var router: ContactInformationRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: ContactInformationListener?
    
    
    /// Reference to the component of this RIB.
    var component: ContactInformationComponent
    
    
    /// Bridge to the ``ContactInformationSwiftUIVIew``.
    private var viewModel = ContactInformationSwiftUIViewModel()
    
    
    /// Constructs an instance of ``ContactInformationInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: ContactInformationComponent) {
        self.component = component
        let presenter = component.contactInformationViewController
        
        super.init(presenter: presenter)
        
        presenter.presentableListener = self
    }
    
    
    /// Customization point that is invoked after self becomes active.
    override func didBecomeActive() {
        super.didBecomeActive()
        configureViewModel()
    }
    
    
    /// Customization point that is invoked before self is fully detached.
    override func willResignActive() {
        super.willResignActive()
    }
    
    
    /// Configures the view model.
    private func configureViewModel() {
        // TODO: Configure the view model.
        presenter.bind(viewModel: self.viewModel)
    }
    
}



/// Conformance to the ``ContactInformationPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``ContactInformationViewController``.
extension ContactInformationInteractor: ContactInformationPresentableListener {}
