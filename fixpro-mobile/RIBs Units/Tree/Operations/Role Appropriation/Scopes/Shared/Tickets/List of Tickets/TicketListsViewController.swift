import Foundation
import RIBs
import RxSwift
import SnapKit
import SwiftUI
import UIKit



/// Contract adhered to by ``TicketListsInteractor``, listing the attributes and/or actions 
/// that ``TicketListsViewController`` is allowed to access or invoke.
protocol TicketListsPresentableListener: AnyObject {}
 
 

/// The visible region of `TicketListsRIB`.
final class TicketListsViewController: UIViewController {
    
    
    /// Reference to ``TicketListsInteractor``.
    weak var presentableListener: TicketListsPresentableListener?
    
    
    /// Reference to ``TicketListsSwiftUIViewModel``.
    weak var viewModel: TicketListsSwiftUIViewModel?
    
    
    /// The SwiftUI view that is displayed by this view controller.
    var hostingController: UIHostingController<TicketListsSwiftUIView>?
    
    
    /// Reference to the active (presented) `ViewControllable`.
    var activeFlow: (any ViewControllable)?
    
    
    /// Customization point that is invoked after self enters the view hierarchy.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Tickets"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        guard hostingController != nil else {
            buildHostingController()
            if case .management = viewModel?.roleContext.role {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open new ticket", 
                                                                    style: .plain, 
                                                                    target: self, 
                                                                    action: #selector(didTapNewTicketButton))
            }
            
            return
        }
    }
    
    
    /// Constructs an instance of ``TicketListsSwiftUIView``, wraps them into `UIHostingController`,
    /// and sets it as the root view of this view controller.
    func buildHostingController() {
        guard let viewModel else { fatalError("ViewModel wasn't yet set.") }
        
        let swiftUIView = TicketListsSwiftUIView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        self.addChild(hostingController)
        self.view.addSubview(hostingController.view)
        
        hostingController.view.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        hostingController.didMove(toParent: self)
        self.hostingController = hostingController
    }
    
    
    @objc func didTapNewTicketButton() {
        viewModel?.didIntendToOpenNewTicket()
    }
    
}



/// Conformance to the ``TicketListsViewControllable`` protocol.
/// Contains everything accessible or invokable by ``TicketListsRouter``.
extension TicketListsViewController: TicketListsViewControllable {
    
    
    /// Inserts the given `ViewControllable` into the view hierarchy OVER the ``hostingViewController``.
    /// - Parameter newFlow: The `ViewControllable` to be inserted.
    /// - Parameter completion: A closure to be executed after the insertion is complete.
    /// 
    /// The default implementation of this method adds the new `ViewControllable` as a child view controller
    /// and adds its view as a subview of the current view controller's view.
    /// - Note: The default implementation of this method REMOVES the previous `ViewControllable` from the view hierarchy.
    func transition(to newFlow: any ViewControllable, completion: (() -> Void)?) {
        Task { @MainActor in
            self.activeFlow?.uiviewController.view.removeFromSuperview()
            self.activeFlow?.uiviewController.removeFromParent()
            
            self.activeFlow = newFlow
            
            self.addChild(newFlow.uiviewController)
            self.view.addSubview(newFlow.uiviewController.view)
            newFlow.uiviewController.didMove(toParent: self)
            
            completion?()
        }
    }
    
    
    /// Clears any `ViewControllable` from the view hierarchy.
    /// - Parameter completion: A closure to be executed after the cleanup is complete.
    /// 
    /// The default implementation of this method removes the current `ViewControllable` from the view hierarchy.
    func cleanUp(completion: (() -> Void)?) {
        Task { @MainActor in
            self.activeFlow?.uiviewController.view.removeFromSuperview()
            self.activeFlow?.uiviewController.removeFromParent()
            
            self.activeFlow = nil
            
            completion?()
        }
    }
    
}



/// Conformance extension to the ``TicketListsPresentable`` protocol.
/// Contains everything accessible or invokable by ``TicketListsInteractor``.
extension TicketListsViewController: TicketListsPresentable {
    
    
    /// Binds the ``TicketListsSwiftUIViewModel`` to the view controller.
    func bind(viewModel: TicketListsSwiftUIViewModel) {
        self.viewModel = viewModel
    }
    
    
    /// Unbinds the ``TicketListsSwiftUIViewModel`` from the view controller.
    func unbindViewModel() {
        self.viewModel = nil
    }
    
}
