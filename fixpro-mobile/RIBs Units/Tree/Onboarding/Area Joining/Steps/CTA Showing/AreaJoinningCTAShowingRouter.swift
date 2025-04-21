import RIBs



/// Contract adhered to by ``AreaJoinningCTAShowingInteractor``, listing the attributes and/or actions 
/// that ``AreaJoinningCTAShowingRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol AreaJoinningCTAShowingInteractable: Interactable {
    var router: AreaJoinningCTAShowingRouting? { get set }
    var listener: AreaJoinningCTAShowingListener? { get set }
}



/// Contract adhered to by ``AreaJoinningCTAShowingViewController``, listing the attributes and/or actions
/// that ``AreaJoinningCTAShowingRouter`` is allowed to access or invoke.
protocol AreaJoinningCTAShowingViewControllable: ViewControllable {}



/// The attachment point of `AreaJoinningCTAShowingRIB`.
final class AreaJoinningCTAShowingRouter: ViewableRouter<AreaJoinningCTAShowingInteractable, AreaJoinningCTAShowingViewControllable> {
    
    
    /// Constructs an instance of ``AreaJoinningCTAShowingRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    override init(interactor: AreaJoinningCTAShowingInteractable, viewController: AreaJoinningCTAShowingViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
}



/// Conformance extension to the ``AreaJoinningCTAShowingRouting`` protocol.
/// Contains everything accessible or invokable by ``AreaJoinningCTAShowingInteractor``.
extension AreaJoinningCTAShowingRouter: AreaJoinningCTAShowingRouting {}
