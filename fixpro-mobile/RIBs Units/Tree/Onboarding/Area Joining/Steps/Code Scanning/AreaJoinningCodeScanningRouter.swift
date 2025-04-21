import RIBs



/// Contract adhered to by ``AreaJoinningCodeScanningInteractor``, listing the attributes and/or actions 
/// that ``AreaJoinningCodeScanningRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol AreaJoinningCodeScanningInteractable: Interactable {
    var router: AreaJoinningCodeScanningRouting? { get set }
    var listener: AreaJoinningCodeScanningListener? { get set }
}



/// Contract adhered to by ``AreaJoinningCodeScanningViewController``, listing the attributes and/or actions
/// that ``AreaJoinningCodeScanningRouter`` is allowed to access or invoke.
protocol AreaJoinningCodeScanningViewControllable: ViewControllable {}



/// The attachment point of `AreaJoinningCodeScanningRIB`.
final class AreaJoinningCodeScanningRouter: ViewableRouter<AreaJoinningCodeScanningInteractable, AreaJoinningCodeScanningViewControllable> {
    
    
    /// Constructs an instance of ``AreaJoinningCodeScanningRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    override init(interactor: AreaJoinningCodeScanningInteractable, viewController: AreaJoinningCodeScanningViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
}



/// Conformance extension to the ``AreaJoinningCodeScanningRouting`` protocol.
/// Contains everything accessible or invokable by ``AreaJoinningCodeScanningInteractor``.
extension AreaJoinningCodeScanningRouter: AreaJoinningCodeScanningRouting {}
