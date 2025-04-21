import RIBs



/// Contract adhered to by ``AreaJoinningFormFillingInteractor``, listing the attributes and/or actions 
/// that ``AreaJoinningFormFillingRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol AreaJoinningFormFillingInteractable: Interactable {
    var router: AreaJoinningFormFillingRouting? { get set }
    var listener: AreaJoinningFormFillingListener? { get set }
}



/// Contract adhered to by ``AreaJoinningFormFillingViewController``, listing the attributes and/or actions
/// that ``AreaJoinningFormFillingRouter`` is allowed to access or invoke.
protocol AreaJoinningFormFillingViewControllable: ViewControllable {}



/// The attachment point of `AreaJoinningFormFillingRIB`.
final class AreaJoinningFormFillingRouter: ViewableRouter<AreaJoinningFormFillingInteractable, AreaJoinningFormFillingViewControllable> {
    
    
    /// Constructs an instance of ``AreaJoinningFormFillingRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    override init(interactor: AreaJoinningFormFillingInteractable, viewController: AreaJoinningFormFillingViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
}



/// Conformance extension to the ``AreaJoinningFormFillingRouting`` protocol.
/// Contains everything accessible or invokable by ``AreaJoinningFormFillingInteractor``.
extension AreaJoinningFormFillingRouter: AreaJoinningFormFillingRouting {}
