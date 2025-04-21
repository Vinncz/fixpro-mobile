import Foundation
import RIBs
import RxSwift
import SnapKit
import SwiftUI
import UIKit



/// Contract adhered to by ``OperationsInteractor``, listing the attributes and/or actions 
/// that ``OperationsViewController`` is allowed to access or invoke.
protocol OperationsPresentableListener: AnyObject {}
 
 

/// The visible region of `OperationsRIB`.
final class OperationsViewController: UIViewController {
    
    
    /// Reference to ``OperationsInteractor``.
    weak var presentableListener: OperationsPresentableListener?
    
    
    /// Reference to ``OperationsSwiftUIViewModel``.
    weak var viewModel: OperationsSwiftUIViewModel?
    
    
    /// The SwiftUI view that is displayed by this view controller.
    var hostingController: UIHostingController<OperationsSwiftUIView>?
    
    
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
    
    
    /// Constructs an instance of ``OperationsSwiftUIView``, wraps them into `UIHostingController`,
    /// and sets it as the root view of this view controller.
    func buildHostingController() {
        guard let viewModel else { fatalError("ViewModel wasn't yet set.") }
        
        let swiftUIView = OperationsSwiftUIView(viewModel: viewModel)
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



/// Conformance to the ``OperationsViewControllable`` protocol.
/// Contains everything accessible or invokable by ``OperationsRouter``.
extension OperationsViewController: OperationsViewControllable {
    
    
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.activeFlow?.uiviewController.view.removeFromSuperview()
            self.activeFlow?.uiviewController.removeFromParent()
            
            self.activeFlow = nil
            
            completion?()
        }
    }
    
}



/// Conformance extension to the ``OperationsPresentable`` protocol.
/// Contains everything accessible or invokable by ``OperationsInteractor``.
extension OperationsViewController: OperationsPresentable {
    
    
    /// Binds the ``OperationsSwiftUIViewModel`` to the view controller.
    func bind(viewModel: OperationsSwiftUIViewModel) {
        self.viewModel = viewModel
    }
    
    
    /// Unbinds the ``OperationsSwiftUIViewModel`` from the view controller.
    func unbindViewModel() {
        self.viewModel = nil
    }
    
}
