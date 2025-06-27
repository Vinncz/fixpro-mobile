import Foundation
import VinUtility
import RIBs
import RxSwift
import SnapKit
import SwiftUI
import UIKit



/// Contract adhered to by ``UpdateContributingInteractor``, listing the attributes and/or actions 
/// that ``UpdateContributingViewController`` is allowed to access or invoke.
protocol UpdateContributingPresentableListener: AnyObject {}
 
 

/// The visible region of `UpdateContributingRIB`.
final class UpdateContributingViewController: UIViewController {
    
    
    /// Reference to ``UpdateContributingInteractor``.
    weak var presentableListener: UpdateContributingPresentableListener?
    
    
    /// Reference to ``UpdateContributingSwiftUIViewModel``.
    weak var viewModel: UpdateContributingSwiftUIViewModel?
    
    
    /// The SwiftUI view that is displayed by this view controller.
    var hostingController: UIHostingController<UpdateContributingSwiftUIView>?
    
    
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
    
    
    /// Constructs an instance of ``UpdateContributingSwiftUIView``, wraps them into `UIHostingController`,
    /// and sets it as the root view of this view controller.
    func buildHostingController() {
        guard let viewModel else { fatalError("ViewModel wasn't yet set.") }
        
        let swiftUIView = UpdateContributingSwiftUIView(viewModel: viewModel)
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



/// Conformance to the ``UpdateContributingViewControllable`` protocol.
/// Contains everything accessible or invokable by ``UpdateContributingRouter``.
extension UpdateContributingViewController: UpdateContributingViewControllable {
    
    
    /// Attaches the given `ViewControllable` into the view hierarchy, becoming the top-most view controller.
    /// - Parameter newFlow: The `ViewControllable` to be attached.
    /// - Parameter completion: A closure to be executed after the operation is complete.
    /// 
    /// > Note: You are responsible for removing the previous `ViewControllable` from the view hierarchy.
    func attach(newFlow: ViewControllable, completion: (() -> Void)?) {
        self.activeFlow = newFlow
        
        self.addChild(newFlow.uiviewController)
        self.view.addSubview(newFlow.uiviewController.view)
        newFlow.uiviewController.didMove(toParent: self)
        
        completion?()
    }
    
    
    /// Clears the  `ViewControllable` from the view hierarchy.
    /// - Parameter completion: A closure to be executed after the cleanup is complete.
    func clear(completion: (() -> Void)?) {
        self.activeFlow?.uiviewController.view.removeFromSuperview()
        self.activeFlow?.uiviewController.removeFromParent()
        self.activeFlow = nil
        
        completion?()
    }
    
    
    /// Removes the hosting controller from the view hierarchy and deallocates it.
    func nilHostingViewController() {
        if let hostingController {
            hostingController.view.removeFromSuperview()
            hostingController.removeFromParent()
            hostingController.didMove(toParent: nil)
        }
        
        self.hostingController = nil
    }
    
}



/// Conformance extension to the ``UpdateContributingPresentable`` protocol.
/// Contains everything accessible or invokable by ``UpdateContributingInteractor``.
extension UpdateContributingViewController: UpdateContributingPresentable {
    
    
    /// Binds the ``UpdateContributingSwiftUIViewModel`` to the view controller.
    func bind(viewModel: UpdateContributingSwiftUIViewModel) {
        self.viewModel = viewModel
    }
    
    
    /// Unbinds the ``UpdateContributingSwiftUIViewModel`` from the view controller.
    func unbindViewModel() {
        self.viewModel = nil
    }
    
}
