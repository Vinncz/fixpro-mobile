import RIBs
import RxSwift
import SwiftUI
import UIKit


/// Collection of methods which ``CodeScanViewController`` can invoke, to perform business logic.
///
/// The `PresentableListener` protocol is responsible to bridge UI events to business logic.  
/// When an interaction with the UI is performed (e.g., pressed a button), ``CodeScanViewController`` **MAY**
/// call method(s) declared here to notify the `Interactor` to perform any associated logics.
///
/// Conformance of this protocol is **EXCLUSIVE** to ``CodeScanInteractor`` (internal use).
/// ``CodeScanViewController``, in turn, can invoke methods declared in this protocol 
/// via its ``CodeScanViewController/presentableListener`` attribute.
protocol CodeScanPresentableListener: AnyObject {
    func viewDidScanAreaJoinCode (withDigestOf: String)
    func viewDidRequestToBeDismissed()
}


/// The UI of `CodeScanRIB`.
final class CodeScanViewController: UIViewController, CodeScanPresentable, CodeScanViewControllable {
    
    weak var presentableListener: CodeScanPresentableListener?
    var viewModel: CodeScanViewModel? = nil
    var hostingController: UIHostingController<AnyView>? = nil
    
    
    /// Logics to perform once the view is loaded.
    override func viewDidLoad () {
        self.title = "Find an Area Join Code"
        view.backgroundColor = .systemBackground
        buildCancelButtonInNavigationBar()
        buildScannerView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hostingController = nil
    }
    
    func bind(viewModel: CodeScanViewModel) {
        self.viewModel = viewModel
    }
    
    func unbindViewModel() {
        self.viewModel = nil
    }
    
}

extension CodeScanViewController {
    
    func buildScannerView() {
        guard let viewModel else { return }
        
        let swiftUIView = AnyView(
            CodeScanView(viewModel: viewModel)
        )
        
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        self.addChild(hostingController)
        self.view.addSubview(hostingController.view)   
        
        hostingController.view.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }
        
        hostingController.didMove(toParent: self)
        self.hostingController = hostingController
    }
    
    func buildCancelButtonInNavigationBar() {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.leftBarButtonItem = cancelButton
    }
    
}

extension CodeScanViewController {
    
    @objc func cancelTapped() {
        presentableListener?.viewDidRequestToBeDismissed()
    }
    
}
