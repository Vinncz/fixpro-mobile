import Foundation
import VinUtility
import RIBs
import RxSwift
import SnapKit
import SwiftUI
import UIKit



/// Contract adhered to by ``WorkEvaluatingInteractor``, listing the attributes and/or actions 
/// that ``WorkEvaluatingViewController`` is allowed to access or invoke.
protocol WorkEvaluatingPresentableListener: AnyObject {
    func didGetDismissed()
}
 
 

/// The visible region of `WorkEvaluatingRIB`.
final class WorkEvaluatingViewController: UIViewController {
    
    
    /// Reference to ``WorkEvaluatingInteractor``.
    weak var presentableListener: WorkEvaluatingPresentableListener?
    
    
    /// Reference to ``WorkEvaluatingSwiftUIViewModel``.
    weak var viewModel: WorkEvaluatingSwiftUIViewModel?
    
    
    /// The SwiftUI view that is displayed by this view controller.
    var hostingController: UIHostingController<WorkEvaluatingSwiftUIView>?
    
    
    /// Reference to the active (presented) `ViewControllable`.
    var activeFlow: (any ViewControllable)?
    
    
    deinit {
        VULogger.log("Deinitialized.")
    }
    
    
    /// Customization point that is invoked after self enters the view hierarchy.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isModalInPresentation = true
        
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = [
                .medium(),
                .large()
            ]
        }
        
        guard hostingController != nil else {
            buildHostingController()
            return
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isBeingDismissed || isMovingFromParent {
            presentableListener?.didGetDismissed()
        }
    }
    
    
    /// Constructs an instance of ``WorkEvaluatingSwiftUIView``, wraps them into `UIHostingController`,
    /// and sets it as the root view of this view controller.
    func buildHostingController() {
        guard let viewModel else { fatalError("ViewModel wasn't yet set.") }
        
        let swiftUIView = WorkEvaluatingSwiftUIView(viewModel: viewModel)
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



/// Conformance to the ``WorkEvaluatingViewControllable`` protocol.
/// Contains everything accessible or invokable by ``WorkEvaluatingRouter``.
extension WorkEvaluatingViewController: WorkEvaluatingViewControllable {
    
    
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



/// Conformance extension to the ``WorkEvaluatingPresentable`` protocol.
/// Contains everything accessible or invokable by ``WorkEvaluatingInteractor``.
extension WorkEvaluatingViewController: WorkEvaluatingPresentable {
    
    
    /// Binds the ``WorkEvaluatingSwiftUIViewModel`` to the view controller.
    func bind(viewModel: WorkEvaluatingSwiftUIViewModel) {
        self.viewModel = viewModel
    }
    
    
    /// Unbinds the ``WorkEvaluatingSwiftUIViewModel`` from the view controller.
    func unbindViewModel() {
        self.viewModel = nil
    }
    
}
