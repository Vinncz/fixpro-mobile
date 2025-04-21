import RIBs
import RxSwift



/// Contract adhered to by ``CrewNewWorkLogRouter``, listing the attributes and/or actions 
/// that ``CrewNewWorkLogInteractor`` is allowed to access or invoke.
protocol CrewNewWorkLogRouting: ViewableRouting {}



/// Contract adhered to by ``CrewNewWorkLogViewController``, listing the attributes and/or actions
/// that ``CrewNewWorkLogInteractor`` is allowed to access or invoke.
protocol CrewNewWorkLogPresentable: Presentable {
    
    
    /// Reference to ``CrewNewWorkLogInteractor``.
    var presentableListener: CrewNewWorkLogPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: CrewNewWorkLogSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `CrewNewWorkLogRIB`'s parent, listing the attributes and/or actions
/// that ``CrewNewWorkLogInteractor`` is allowed to access or invoke.
protocol CrewNewWorkLogListener: AnyObject {}



/// The functionality centre of `CrewNewWorkLogRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class CrewNewWorkLogInteractor: PresentableInteractor<CrewNewWorkLogPresentable>, CrewNewWorkLogInteractable {
    
    
    /// Reference to ``CrewNewWorkLogRouter``.
    weak var router: CrewNewWorkLogRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: CrewNewWorkLogListener?
    
    
    /// Reference to the component of this RIB.
    var component: CrewNewWorkLogComponent
    
    
    /// Bridge to the ``CrewNewWorkLogSwiftUIVIew``.
    private var viewModel = CrewNewWorkLogSwiftUIViewModel()
    
    
    /// Constructs an instance of ``CrewNewWorkLogInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: CrewNewWorkLogComponent) {
        self.component = component
        let presenter = component.crewNewWorkLogViewController
        
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



/// Conformance to the ``CrewNewWorkLogPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``CrewNewWorkLogViewController``.
extension CrewNewWorkLogInteractor: CrewNewWorkLogPresentableListener {}
