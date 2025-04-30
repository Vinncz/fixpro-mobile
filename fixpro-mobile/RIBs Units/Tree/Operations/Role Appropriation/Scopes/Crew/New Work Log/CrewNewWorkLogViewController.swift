import Foundation
import VinUtility
import RIBs
import RxSwift
import SnapKit
import SwiftUI
import UIKit



/// Contract adhered to by ``CrewNewWorkLogInteractor``, listing the attributes and/or actions 
/// that ``CrewNewWorkLogViewController`` is allowed to access or invoke.
protocol CrewNewWorkLogPresentableListener: AnyObject {
    func didGetDismissed()
}
 
 

/// The visible region of `CrewNewWorkLogRIB`.
final class CrewNewWorkLogViewController: UIViewController {
    
    
    /// Reference to ``CrewNewWorkLogInteractor``.
    weak var presentableListener: CrewNewWorkLogPresentableListener?
    
    
    /// Reference to ``CrewNewWorkLogSwiftUIViewModel``.
    weak var viewModel: CrewNewWorkLogSwiftUIViewModel?
    
    
    /// The SwiftUI view that is displayed by this view controller.
    var hostingController: UIHostingController<CrewNewWorkLogSwiftUIView>?
    
    
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
    
    
    /// Constructs an instance of ``CrewNewWorkLogSwiftUIView``, wraps them into `UIHostingController`,
    /// and sets it as the root view of this view controller.
    func buildHostingController() {
        guard let viewModel else { fatalError("ViewModel wasn't yet set.") }
        
        let swiftUIView = CrewNewWorkLogSwiftUIView(viewModel: viewModel)
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



/// Conformance to the ``CrewNewWorkLogViewControllable`` protocol.
/// Contains everything accessible or invokable by ``CrewNewWorkLogRouter``.
extension CrewNewWorkLogViewController: CrewNewWorkLogViewControllable {
    
    
    /// Inserts the given `ViewControllable` into the view hierarchy OVER the ``hostingViewController``.
    /// - Parameter newFlow: The `ViewControllable` to be inserted.
    /// - Parameter completion: A closure to be executed after the insertion is complete.
    /// 
    /// The default implementation of this method adds the new `ViewControllable` as a child view controller
    /// and adds its view as a subview of the current view controller's view.
    /// - Note: The default implementation of this method REMOVES the previous `ViewControllable` from the view hierarchy.
    func transition(to newFlow: any ViewControllable, completion: (() -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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



/// Conformance extension to the ``CrewNewWorkLogPresentable`` protocol.
/// Contains everything accessible or invokable by ``CrewNewWorkLogInteractor``.
extension CrewNewWorkLogViewController: CrewNewWorkLogPresentable {
    
    
    /// Binds the ``CrewNewWorkLogSwiftUIViewModel`` to the view controller.
    func bind(viewModel: CrewNewWorkLogSwiftUIViewModel) {
        self.viewModel = viewModel
    }
    
    
    /// Unbinds the ``CrewNewWorkLogSwiftUIViewModel`` from the view controller.
    func unbindViewModel() {
        self.viewModel = nil
    }
    
}
