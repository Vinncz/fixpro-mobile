import RIBs
import RxSwift



/// Contract adhered to by ``MemberRoleScopingRouter``, listing the attributes and/or actions 
/// that ``MemberRoleScopingInteractor`` is allowed to access or invoke.
protocol MemberRoleScopingRouting: ViewableRouting {}



/// Contract adhered to by ``MemberRoleScopingViewController``, listing the attributes and/or actions
/// that ``MemberRoleScopingInteractor`` is allowed to access or invoke.
protocol MemberRoleScopingPresentable: Presentable {
    
    
    /// Reference to ``MemberRoleScopingInteractor``.
    var presentableListener: MemberRoleScopingPresentableListener? { get set }
    
}



/// Contract adhered to by the Interactor of `MemberRoleScopingRIB`'s parent, listing the attributes and/or actions
/// that ``MemberRoleScopingInteractor`` is allowed to access or invoke.
protocol MemberRoleScopingListener: AnyObject {}



/// The functionality centre of `MemberRoleScopingRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class MemberRoleScopingInteractor: PresentableInteractor<MemberRoleScopingPresentable>, MemberRoleScopingInteractable {
    
    
    /// Reference to ``MemberRoleScopingRouter``.
    weak var router: MemberRoleScopingRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: MemberRoleScopingListener?
    
    
    /// Reference to the component of this RIB.
    var component: MemberRoleScopingComponent
    
    
    /// Constructs an instance of ``MemberRoleScopingInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: MemberRoleScopingComponent) {
        self.component = component
        let presenter = component.memberRoleScopingViewController
        
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



/// Conformance to the ``MemberRoleScopingPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``MemberRoleScopingViewController``
extension MemberRoleScopingInteractor: MemberRoleScopingPresentableListener {}
