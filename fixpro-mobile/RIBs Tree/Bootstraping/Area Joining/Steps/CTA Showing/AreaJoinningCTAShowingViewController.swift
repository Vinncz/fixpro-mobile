import Foundation
import RIBs
import RxSwift
import SnapKit
import SwiftUI
import UIKit



/// Contract adhered to by ``AreaJoinningCTAShowingInteractor``, listing the attributes and/or actions 
/// that ``AreaJoinningCTAShowingViewController`` is allowed to access or invoke.
protocol AreaJoinningCTAShowingPresentableListener: AnyObject {
    func didFinishPairing()
}
 
 

/// The visible region of `AreaJoinningCTAShowingRIB`.
final class AreaJoinningCTAShowingViewController: UIViewController {
    
    
    /// Reference to ``AreaJoinningCTAShowingInteractor``.
    weak var presentableListener: AreaJoinningCTAShowingPresentableListener?
    
    
    /// Reference to ``AreaJoinningCTAShowingSwiftUIViewModel``.
    weak var viewModel: AreaJoinningCTAShowingSwiftUIViewModel?
    
    
    /// The SwiftUI view that is displayed by this view controller.
    var hostingController: UIHostingController<AreaJoinningCTAShowingSwiftUIView>?
    
    
    /// Customization point that is invoked after self enters the view hierarchy.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.title = "Submitted successfully"
        
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(finishPairing))
        self.navigationItem.rightBarButtonItem = done
        
        self.navigationItem.hidesBackButton = true
        
        guard hostingController != nil else {
            buildHostingController()
            return
        }
    }
    
    
    /// Constructs an instance of ``AreaJoinningCTAShowingSwiftUIView``, wraps them into `UIHostingController`,
    /// and sets it as the root view of this view controller.
    func buildHostingController() {
        guard let viewModel else { fatalError("ViewModel wasn't yet set.") }
        
        let swiftUIView = AreaJoinningCTAShowingSwiftUIView(viewModel: viewModel)
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
    
    
    @objc func finishPairing () {
        presentableListener?.didFinishPairing()
    }
    
}



/// Conformance to the ``AreaJoinningCTAShowingViewControllable`` protocol.
/// Contains everything accessible or invokable by ``AreaJoinningCTAShowingRouter``.
extension AreaJoinningCTAShowingViewController: AreaJoinningCTAShowingViewControllable {}



/// Conformance extension to the ``AreaJoinningCTAShowingPresentable`` protocol.
/// Contains everything accessible or invokable by ``AreaJoinningCTAShowingInteractor``.
extension AreaJoinningCTAShowingViewController: AreaJoinningCTAShowingPresentable {
    
    
    /// Binds the ``AreaJoinningCTAShowingSwiftUIViewModel`` to the view controller.
    func bind(viewModel: AreaJoinningCTAShowingSwiftUIViewModel) {
        self.viewModel = viewModel
    }
    
    
    /// Unbinds the ``AreaJoinningCTAShowingSwiftUIViewModel`` from the view controller.
    func unbindViewModel() {
        self.viewModel = nil
    }
    
}
