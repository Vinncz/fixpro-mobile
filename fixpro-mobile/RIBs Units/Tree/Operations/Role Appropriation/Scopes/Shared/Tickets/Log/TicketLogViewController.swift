import Foundation
import VinUtility
import RIBs
import RxSwift
import SnapKit
import SwiftUI
import UIKit



/// Contract adhered to by ``TicketLogInteractor``, listing the attributes and/or actions 
/// that ``TicketLogViewController`` is allowed to access or invoke.
protocol TicketLogPresentableListener: AnyObject {
    func navigateToTicketDetail()
}
 
 

/// The visible region of `TicketLogRIB`.
final class TicketLogViewController: UIViewController {
    
    
    /// Reference to ``TicketLogInteractor``.
    weak var presentableListener: TicketLogPresentableListener?
    
    
    /// Reference to ``TicketLogSwiftUIViewModel``.
    weak var viewModel: TicketLogSwiftUIViewModel?
    
    
    /// The SwiftUI view that is displayed by this view controller.
    var hostingController: UIHostingController<TicketLogSwiftUIView>?
    
    
    /// Reference to the active (presented) `ViewControllable`.
    var activeFlow: (any ViewControllable)?
    
    
    /// Customization point that is invoked after self enters the view hierarchy.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Ticket Log"
        
        guard hostingController != nil else {
            buildHostingController()
            return
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParent || isBeingDismissed {
            presentableListener?.navigateToTicketDetail()
        }
    }
    
    
    deinit {
        VULogger.log("Deinitialized.")
    }
    
    
    /// Constructs an instance of ``TicketLogSwiftUIView``, wraps them into `UIHostingController`,
    /// and sets it as the root view of this view controller.
    func buildHostingController() {
        guard let viewModel else { fatalError("ViewModel wasn't yet set.") }
        
        let swiftUIView = TicketLogSwiftUIView(viewModel: viewModel)
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
    
}



/// Conformance to the ``TicketLogViewControllable`` protocol.
/// Contains everything accessible or invokable by ``TicketLogRouter``.
extension TicketLogViewController: TicketLogViewControllable {
    
    
    /// Attaches the given `ViewControllable` into the view hierarchy, becoming the top-most view controller.
    /// - Parameter newFlow: The `ViewControllable` to be attached.
    /// - Parameter completion: A closure to be executed after the operation is complete.
    /// 
    /// > Note: You are responsible for removing the previous `ViewControllable` from the view hierarchy.
    func attach(newFlow: ViewControllable, completion: (() -> Void)?) {
        Task { @MainActor in
            self.activeFlow = newFlow
            
            self.addChild(newFlow.uiviewController)
            self.view.addSubview(newFlow.uiviewController.view)
            newFlow.uiviewController.didMove(toParent: self)
            
            completion?()
        }
    }
    
    
    /// Clears the  `ViewControllable` from the view hierarchy.
    /// - Parameter completion: A closure to be executed after the cleanup is complete.
    func clear(completion: (() -> Void)?) {
        Task { @MainActor in
            self.activeFlow?.uiviewController.view.removeFromSuperview()
            self.activeFlow?.uiviewController.removeFromParent()
            
            self.activeFlow = nil
            
            completion?()
        }
    }
    
    
    /// Removes the hosting controller from the view hierarchy and deallocates it.
    func nilHostingViewController() {
        Task { @MainActor in
            if let hostingController {
                hostingController.view.removeFromSuperview()
                hostingController.removeFromParent()
                hostingController.didMove(toParent: nil)
            }
            
            self.hostingController = nil
        }
    }
    
}



/// Conformance extension to the ``TicketLogPresentable`` protocol.
/// Contains everything accessible or invokable by ``TicketLogInteractor``.
extension TicketLogViewController: TicketLogPresentable {
    
    
    /// Binds the ``TicketLogSwiftUIViewModel`` to the view controller.
    func bind(viewModel: TicketLogSwiftUIViewModel) {
        self.viewModel = viewModel
    }
    
    
    /// Unbinds the ``TicketLogSwiftUIViewModel`` from the view controller.
    func unbindViewModel() {
        self.viewModel = nil
    }
    
}
