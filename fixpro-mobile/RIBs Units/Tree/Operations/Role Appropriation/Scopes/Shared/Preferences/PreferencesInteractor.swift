import RIBs
import RxSwift



/// Contract adhered to by ``PreferencesRouter``, listing the attributes and/or actions 
/// that ``PreferencesInteractor`` is allowed to access or invoke.
protocol PreferencesRouting: ViewableRouting {}



/// Contract adhered to by ``PreferencesViewController``, listing the attributes and/or actions
/// that ``PreferencesInteractor`` is allowed to access or invoke.
protocol PreferencesPresentable: Presentable {
    
    
    /// Reference to ``PreferencesInteractor``.
    var presentableListener: PreferencesPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: PreferencesSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `PreferencesRIB`'s parent, listing the attributes and/or actions
/// that ``PreferencesInteractor`` is allowed to access or invoke.
protocol PreferencesListener: AnyObject {}



/// The functionality centre of `PreferencesRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class PreferencesInteractor: PresentableInteractor<PreferencesPresentable>, PreferencesInteractable {
    
    
    /// Reference to ``PreferencesRouter``.
    weak var router: PreferencesRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: PreferencesListener?
    
    
    /// Reference to the component of this RIB.
    var component: PreferencesComponent
    
    
    /// Bridge to the ``PreferencesSwiftUIVIew``.
    private var viewModel = PreferencesSwiftUIViewModel()
    
    
    /// Constructs an instance of ``PreferencesInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: PreferencesComponent) {
        self.component = component
        let presenter = component.preferencesViewController
        
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



/// Conformance to the ``PreferencesPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``PreferencesViewController``.
extension PreferencesInteractor: PreferencesPresentableListener {}
