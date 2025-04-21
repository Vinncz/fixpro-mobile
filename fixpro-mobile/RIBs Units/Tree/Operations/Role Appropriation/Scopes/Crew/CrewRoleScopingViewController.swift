import Foundation
import RIBs
import RxSwift
import UIKit



/// Contract adhered to by ``CrewRoleScopingInteractor``, listing the attributes and/or actions 
/// that ``CrewRoleScopingViewController`` is allowed to access or invoke.
protocol CrewRoleScopingPresentableListener: AnyObject {}
 
 

/// The visible region of `CrewRoleScopingRIB`.
final class CrewRoleScopingViewController: UITabBarController {
    
    
    /// Reference to ``CrewRoleScopingInteractor``.
    weak var presentableListener: CrewRoleScopingPresentableListener?
    
    
    /// Reference to the active (presented) `ViewControllable`.
    var activeFlow: (any ViewControllable)?
    
    
    /// Expected to be handled by ``CrewRoleScopingRouter``.
    var newTicketViewController: (() -> UIViewController)?
    
    
    /// Customization point that is invoked after self enters the view hierarchy.
    override func viewDidLoad() {
        delegate = self
        super.viewDidLoad()
    }
    
}



/// Conformance to the ``CrewRoleScopingViewControllable`` protocol.
/// Contains everything accessible or invokable by ``CrewRoleScopingRouter``.
extension CrewRoleScopingViewController: UITabBarControllerDelegate {
    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.tabBarItem.tag == .MODALLY_PRESENTED_VIEW_CONTROLLER {
            guard let ntvc = newTicketViewController?() else { 
                return true 
            }
            
            ntvc.modalPresentationStyle = .fullScreen
            present(ntvc, animated: true)
            return false
        }
        
        return true
    }
    
}



/// Conformance to the ``CrewRoleScopingViewControllable`` protocol.
/// Contains everything accessible or invokable by ``CrewRoleScopingRouter``.
extension CrewRoleScopingViewController: CrewRoleScopingViewControllable {}



/// Conformance extension to the ``CrewRoleScopingPresentable`` protocol.
/// Contains everything accessible or invokable by ``CrewRoleScopingInteractor``.
extension CrewRoleScopingViewController: CrewRoleScopingPresentable {}
