import Foundation
import RIBs
import RxSwift
import UIKit



/// Contract adhered to by ``AreaJoinningInteractor``, listing the attributes and/or actions 
/// that ``AreaJoinningViewController`` is allowed to access or invoke.
protocol AreaJoinningPresentableListener: AnyObject {}
 
 

/// The visible region of `AreaJoinningRIB`.
final class AreaJoinningViewController: UINavigationController {
    
    
    /// Reference to ``AreaJoinningInteractor``.
    weak var presentableListener: AreaJoinningPresentableListener?
    
    
    /// Reference to the active (presented) `ViewControllable`.
    var activeFlow: (any ViewControllable)?
    
    
    /// Customization point that is invoked after self enters the view hierarchy.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .fullScreen
        view.backgroundColor = .systemBackground
    }
    
}



/// Conformance to the ``AreaJoinningViewControllable`` protocol.
/// Contains everything accessible or invokable by ``AreaJoinningRouter``
extension AreaJoinningViewController: AreaJoinningViewControllable {}



/// Conformance extension to the ``AreaJoinningPresentable`` protocol.
/// Contains everything accessible or invokable by ``AreaJoinningInteractor``.
extension AreaJoinningViewController: AreaJoinningPresentable {}
