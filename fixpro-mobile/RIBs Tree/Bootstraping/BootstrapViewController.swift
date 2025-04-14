import Foundation
import RIBs
import RxSwift
import SnapKit
import SwiftUI
import UIKit



/// Contract adhered to by ``BootstrapInteractor``, listing the attributes and/or actions 
/// that ``BootstrapViewController`` is allowed to access or invoke.
protocol BootstrapPresentableListener: AnyObject {}
 
 

/// The visible region of `BootstrapRIB`.
final class BootstrapViewController: UIViewController {
    
    
    /// Reference to ``BootstrapInteractor``.
    weak var presentableListener: BootstrapPresentableListener?
    
    
    /// Reference to ``BootstrapSwiftUIViewModel``.
    weak var viewModel: BootstrapSwiftUIViewModel?
    
    
    /// The SwiftUI view that is displayed by this view controller.
    var hostingController: UIHostingController<BootstrapSwiftUIView>?
    
    
    /// Reference to the active (presented) `ViewControllable`.
    var activeFlow: (any ViewControllable)?
    
    
    /// Customization point that is invoked after self enters the view hierarchy.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard hostingController != nil else {
            buildHostingController()
            return
        }
    }
    
    
    /// Constructs an instance of ``BootstrapSwiftUIView``, wraps them into `UIHostingController`,
    /// and sets it as the root view of this view controller.
    func buildHostingController() {
        guard let viewModel else { fatalError("ViewModel wasn't yet set.") }
        
        let swiftUIView = BootstrapSwiftUIView(viewModel: viewModel)
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



/// Conformance to the ``BootstrapViewControllable`` protocol.
/// Contains everything accessible or invokable by ``BootstrapRouter``
extension BootstrapViewController: BootstrapViewControllable {
    
    
    /// Inserts the given `ViewControllable` into the view hierarchy.
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.activeFlow?.uiviewController.view.removeFromSuperview()
            self.activeFlow?.uiviewController.removeFromParent()
            
            self.activeFlow = nil
            
            completion?()
        }
    }
    
    
    func present(_ flow: any ViewControllable) {
        self.activeFlow = flow
        self.present(flow.uiviewController, animated: true)
    }
    
    func dismiss() {
        if self.activeFlow != nil {
            self.dismiss(animated: true)
            self.activeFlow = nil
        }
    }
    
}



/// Conformance extension to the ``BootstrapPresentable`` protocol.
/// Contains everything accessible or invokable by ``BootstrapInteractor``
extension BootstrapViewController: BootstrapPresentable {
    
    
    /// Binds the ``BootstrapSwiftUIViewModel`` to the view controller.
    func bind(viewModel: BootstrapSwiftUIViewModel) {
        self.viewModel = viewModel
    }
    
    
    /// Unbinds the ``BootstrapSwiftUIViewModel`` from the view controller.
    func unbindViewModel() {
        self.viewModel = nil
    }
    
}
