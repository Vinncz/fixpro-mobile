import RIBs
import RxSwift



/// Contract adhered to by ``CrewDelegatingRouter``, listing the attributes and/or actions 
/// that ``CrewDelegatingInteractor`` is allowed to access or invoke.
protocol CrewDelegatingRouting: ViewableRouting {}



/// Contract adhered to by ``CrewDelegatingViewController``, listing the attributes and/or actions
/// that ``CrewDelegatingInteractor`` is allowed to access or invoke.
protocol CrewDelegatingPresentable: Presentable {
    
    
    /// Reference to ``CrewDelegatingInteractor``.
    var presentableListener: CrewDelegatingPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: CrewDelegatingSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `CrewDelegatingRIB`'s parent, listing the attributes and/or actions
/// that ``CrewDelegatingInteractor`` is allowed to access or invoke.
protocol CrewDelegatingListener: AnyObject {}



/// The functionality centre of `CrewDelegatingRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class CrewDelegatingInteractor: PresentableInteractor<CrewDelegatingPresentable>, CrewDelegatingInteractable {
    
    
    /// Reference to ``CrewDelegatingRouter``.
    weak var router: CrewDelegatingRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: CrewDelegatingListener?
    
    
    /// Reference to the component of this RIB.
    var component: CrewDelegatingComponent
    
    
    /// Bridge to the ``CrewDelegatingSwiftUIVIew``.
    private var viewModel = CrewDelegatingSwiftUIViewModel()
    
    
    /// Constructs an instance of ``CrewDelegatingInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: CrewDelegatingComponent) {
        self.component = component
        let presenter = component.crewDelegatingViewController
        
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



/// Conformance to the ``CrewDelegatingPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``CrewDelegatingViewController``.
extension CrewDelegatingInteractor: CrewDelegatingPresentableListener {}
