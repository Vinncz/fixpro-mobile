import Foundation
import RIBs
import RxSwift
import SnapKit
import SwiftUI
import UIKit



/// Contract adhered to by ``AreaJoinningCodeScanningInteractor``, listing the attributes and/or actions 
/// that ``AreaJoinningCodeScanningViewController`` is allowed to access or invoke.
protocol AreaJoinningCodeScanningPresentableListener: AnyObject {
    func viewDidScanAreaJoinCode (withDigestOf: String)
    func viewDidRequestToBeDismissed()
}
 
 

/// The visible region of `AreaJoinningCodeScanningRIB`.
final class AreaJoinningCodeScanningViewController: UIViewController {
    
    
    /// Reference to ``AreaJoinningCodeScanningInteractor``.
    weak var presentableListener: AreaJoinningCodeScanningPresentableListener?
    
    
    /// Reference to ``AreaJoinningCodeScanningSwiftUIViewModel``.
    weak var viewModel: AreaJoinningCodeScanningSwiftUIViewModel?
    
    
    /// The SwiftUI view that is displayed by this view controller.
    var hostingController: UIHostingController<AreaJoinningCodeScanningSwiftUIView>?
    
    
    /// Customization point that is invoked after self enters the view hierarchy.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Find an Area Join Code"
        view.backgroundColor = .systemBackground
        
        guard hostingController != nil else {
            buildCancelButtonInNavigationBar()
            setToolbarItems([UIBarButtonItem(image: UIImage(systemName: "character.cursor.ibeam"), style: .plain, target: self, action: #selector(didTapManualEntryButton))], animated: true)
            self.navigationController?.isToolbarHidden = false
            buildHostingController()
            return
        }
    }
    
    
    /// Constructs an instance of ``AreaJoinningCodeScanningSwiftUIView``, wraps them into `UIHostingController`,
    /// and sets it as the root view of this view controller.
    func buildHostingController() {
        guard let viewModel else { fatalError("ViewModel wasn't yet set.") }
        
        let swiftUIView = AreaJoinningCodeScanningSwiftUIView(viewModel: viewModel)
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
    
    func buildCancelButtonInNavigationBar() {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancelScanButton))
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    @objc func didTapCancelScanButton() {
        presentableListener?.viewDidRequestToBeDismissed()
    }
    
    @objc func didTapManualEntryButton() {
        viewModel?.isInputingManually = true
    }
    
}



/// Conformance to the ``AreaJoinningCodeScanningViewControllable`` protocol.
/// Contains everything accessible or invokable by ``AreaJoinningCodeScanningRouter``.
extension AreaJoinningCodeScanningViewController: AreaJoinningCodeScanningViewControllable {}



/// Conformance extension to the ``AreaJoinningCodeScanningPresentable`` protocol.
/// Contains everything accessible or invokable by ``AreaJoinningCodeScanningInteractor``.
extension AreaJoinningCodeScanningViewController: AreaJoinningCodeScanningPresentable {
    
    
    /// Binds the ``AreaJoinningCodeScanningSwiftUIViewModel`` to the view controller.
    func bind(viewModel: AreaJoinningCodeScanningSwiftUIViewModel) {
        self.viewModel = viewModel
    }
    
    
    /// Unbinds the ``AreaJoinningCodeScanningSwiftUIViewModel`` from the view controller.
    func unbindViewModel() {
        self.viewModel = nil
    }
    
}


#Preview {
    AreaJoinningCodeScanningViewController()
}
