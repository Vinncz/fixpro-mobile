import Foundation
import VinUtility
import RIBs
import RxSwift
import UIKit



/// Contract adhered to by ``ManagementRoleScopingInteractor``, listing the attributes and/or actions 
/// that ``ManagementRoleScopingViewController`` is allowed to access or invoke.
protocol ManagementRoleScopingPresentableListener: AnyObject {}
 
 

/// The visible region of `ManagementRoleScopingRIB`.
final class ManagementRoleScopingViewController: UITabBarController {
    
    
    /// Reference to ``ManagementRoleScopingInteractor``.
    weak var presentableListener: ManagementRoleScopingPresentableListener?
    
    
    /// Reference to the active (presented) `ViewControllable`.
    var activeFlow: (any ViewControllable)?
    
    
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



extension ManagementRoleScopingViewController: UITabBarControllerDelegate {
    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    
}



/// Conformance to the ``ManagementRoleScopingViewControllable`` protocol.
/// Contains everything accessible or invokable by ``ManagementRoleScopingRouter``.
extension ManagementRoleScopingViewController: ManagementRoleScopingViewControllable {}



/// Conformance extension to the ``ManagementRoleScopingPresentable`` protocol.
/// Contains everything accessible or invokable by ``ManagementRoleScopingInteractor``.
extension ManagementRoleScopingViewController: ManagementRoleScopingPresentable {}
