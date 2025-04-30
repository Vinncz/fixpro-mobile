import Foundation
import RIBs
import RxSwift
import SnapKit
import SwiftUI
import UIKit



/// Contract adhered to by ``InboxNavigatorInteractor``, listing the attributes and/or actions 
/// that ``InboxNavigatorViewController`` is allowed to access or invoke.
protocol InboxNavigatorPresentableListener: AnyObject {}



/// The visible region of `InboxNavigatorRIB`.
final class InboxNavigatorNavigationController: UINavigationController {
    
    
    /// Reference to ``InboxNavigatorInteractor``.
    weak var presentableListener: InboxNavigatorPresentableListener?
    
    
    /// Customization point that is invoked after self enters the view hierarchy.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBarItem: UITabBarItem = UITabBarItem(title: "Inbox", 
                                                    image: UIImage(systemName: "bell"), 
                                                    selectedImage: UIImage(systemName: "bell.fill"))
        self.tabBarItem = tabBarItem
    }
    
}



/// Conformance to the ``InboxNavigatorViewControllable`` protocol.
/// Contains everything accessible or invokable by ``InboxNavigatorRouter``.
extension InboxNavigatorNavigationController: InboxNavigatorViewControllable {
    
    
    /// Pushes the given `ViewControllable` onto the navigation stack.
    /// - Parameter viewControllable: The `ViewControllable` to be pushed.
    /// - Parameter animated: A Boolean value that indicates whether the transition should be animated.
    func push(_ viewControllable: ViewControllable, animated: Bool) {
        self.pushViewController(viewControllable.uiviewController, animated: animated)
    }
    
    
    /// Pops the top view controller off the navigation stack.
    /// - Parameter animated: A Boolean value that indicates whether the transition should be animated.
    /// - Returns: An optional view controller that was popped.
    @discardableResult func pop(animated: Bool) -> UIViewController? {
        self.popViewController(animated: animated)
    }
    
    
    /// Pops all view controllers on the navigation stack until the root view controller is at the top.
    /// - Parameter animated: A Boolean value that indicates whether the transition should be animated.
    /// - Note: This method does not remove the root view controller from the navigation stack.
    /// - Returns: An optional array of view controllers that were popped.
    @discardableResult func popToRoot(animated: Bool) -> [UIViewController]? {
        self.popToRootViewController(animated: animated)
    }
    
    
    /// Sets the view controllers of the navigation stack.
    /// - Parameter viewControllables: An array of `ViewControllable` to be set as the new view controllers.
    /// - Parameter animated: A Boolean value that indicates whether the transition should be animated.
    func set(_ viewControllables: [ViewControllable], animated: Bool) {
        let vcs = viewControllables.map { $0.uiviewController }
        self.setViewControllers(vcs, animated: animated)
    }
    
}



/// Conformance extension to the ``InboxNavigatorPresentable`` protocol.
/// Contains everything accessible or invokable by ``InboxNavigatorInteractor``.
extension InboxNavigatorNavigationController: InboxNavigatorPresentable {}
