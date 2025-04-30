import Foundation
import VinUtility
import RIBs
import RxSwift
import SnapKit
import SwiftUI
import UIKit



/// Contract adhered to by ``TicketNavigatorInteractor``, listing the attributes and/or actions 
/// that ``TicketNavigatorViewController`` is allowed to access or invoke.
protocol TicketNavigatorPresentableListener: AnyObject {}



/// The visible region of `TicketNavigatorRIB`.
final class TicketNavigatorNavigationController: UINavigationController {
    
    
    /// Reference to ``TicketNavigatorInteractor``.
    weak var presentableListener: TicketNavigatorPresentableListener?
    
    
    /// Customization point that is invoked after self enters the view hierarchy.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ticketListRouterUITabBarItem = UITabBarItem(title: "Tickets", 
                                                        image: UIImage(systemName: "ticket"), 
                                                        selectedImage: UIImage(systemName: "ticket.fill"))
        self.tabBarItem = ticketListRouterUITabBarItem
    }
    
}



/// Conformance to the ``TicketNavigatorViewControllable`` protocol.
/// Contains everything accessible or invokable by ``TicketNavigatorRouter``.
extension TicketNavigatorNavigationController: TicketNavigatorViewControllable {
    
    
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



/// Conformance extension to the ``TicketNavigatorPresentable`` protocol.
/// Contains everything accessible or invokable by ``TicketNavigatorInteractor``.
extension TicketNavigatorNavigationController: TicketNavigatorPresentable {}
