import Foundation
import RIBs
import RxSwift
import UIKit
import VinUtility



/// Contract adhered to by ``MemberRoleScopingInteractor``, listing the attributes and/or actions 
/// that ``MemberRoleScopingViewController`` is allowed to access or invoke.
protocol MemberRoleScopingPresentableListener: AnyObject {}
 
 

/// The visible region of `MemberRoleScopingRIB`.
final class MemberRoleScopingViewController: UITabBarController {
    
    
    /// Reference to ``MemberRoleScopingInteractor``.
    weak var presentableListener: MemberRoleScopingPresentableListener?
    
    
    /// Reference to the active (presented) `ViewControllable`.
    var activeFlow: (any ViewControllable)?
    
    
    /// Assumed to be handled by ``MemberRoleScopingRouter``.
    var newTicketViewController: (() -> UIViewController)?
    
    
    /// Customization point that is invoked after self enters the view hierarchy.
    override func viewDidLoad() {
        delegate = self
        super.viewDidLoad()
        hidesBottomBarWhenPushed = true
    }
    
    
    deinit {
        VULogger.log("Deinitialized.")
    }
    
}



extension MemberRoleScopingViewController: UITabBarControllerDelegate {
    
    
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



/// Conformance to the ``MemberRoleScopingViewControllable`` protocol.
/// Contains everything accessible or invokable by ``MemberRoleScopingRouter``.
extension MemberRoleScopingViewController: MemberRoleScopingViewControllable {}



/// Conformance extension to the ``MemberRoleScopingPresentable`` protocol.
/// Contains everything accessible or invokable by ``MemberRoleScopingInteractor``.
extension MemberRoleScopingViewController: MemberRoleScopingPresentable {}
