import RIBs
import RxSwift



/// Contract adhered to by ``CrewRoleScopingRouter``, listing the attributes and/or actions 
/// that ``CrewRoleScopingInteractor`` is allowed to access or invoke.
protocol CrewRoleScopingRouting: ViewableRouting {}



/// Contract adhered to by ``CrewRoleScopingViewController``, listing the attributes and/or actions
/// that ``CrewRoleScopingInteractor`` is allowed to access or invoke.
protocol CrewRoleScopingPresentable: Presentable {
    
    
    /// Reference to ``CrewRoleScopingInteractor``.
    var presentableListener: CrewRoleScopingPresentableListener? { get set }
    
}



/// Contract adhered to by the Interactor of `CrewRoleScopingRIB`'s parent, listing the attributes and/or actions
/// that ``CrewRoleScopingInteractor`` is allowed to access or invoke.
protocol CrewRoleScopingListener: AnyObject {}



/// The functionality centre of `CrewRoleScopingRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class CrewRoleScopingInteractor: PresentableInteractor<CrewRoleScopingPresentable>, CrewRoleScopingInteractable {
    
    
    /// Reference to ``CrewRoleScopingRouter``.
    weak var router: CrewRoleScopingRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: CrewRoleScopingListener?
    
    
    /// Reference to the component of this RIB.
    var component: CrewRoleScopingComponent
    
    
    /// Constructs an instance of ``CrewRoleScopingInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: CrewRoleScopingComponent) {
        self.component = component
        let presenter = component.crewRoleScopingViewController
        
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



/// Conformance to the ``CrewRoleScopingPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``CrewRoleScopingViewController``
extension CrewRoleScopingInteractor: CrewRoleScopingPresentableListener {}
