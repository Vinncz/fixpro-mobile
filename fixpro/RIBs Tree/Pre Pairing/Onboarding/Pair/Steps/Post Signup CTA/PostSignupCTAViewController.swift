import RIBs
import RxSwift
import SwiftUI
import UIKit


/// Collection of methods which ``PostSignupCTAViewController`` can invoke, to perform business logic.
///
/// The `PresentableListener` protocol is responsible to bridge UI events to business logic.  
/// When an interaction with the UI is performed (e.g., pressed a button), ``PostSignupCTAViewController`` **MAY**
/// call method(s) declared here to notify the `Interactor` to perform any associated logics.
///
/// Conformance of this protocol is **EXCLUSIVE** to ``PostSignupCTAInteractor`` (internal use).
/// ``PostSignupCTAViewController``, in turn, can invoke methods declared in this protocol 
/// via its ``PostSignupCTAViewController/presentableListener`` attribute.
protocol PostSignupCTAPresentableListener: AnyObject {
    func didFinishPairing()
}


/// The UI of `PostSignupCTARIB`.
final class PostSignupCTAViewController: UIViewController, PostSignupCTAPresentable, PostSignupCTAViewControllable {
    
    
    /// The reference to ``PostSignupCTAInteractor``.
    /// 
    /// The word 'presentableListener' is a convention used in RIBs, which refer to the `Interactor`
    /// who reacts to UI events from their descendants. (It 'listens' to them).
    weak var presentableListener: PostSignupCTAPresentableListener?
    var hostingController: UIHostingController<AnyView>? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.title = "Submitted successfully"
        
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(finishPairing))
        self.navigationItem.rightBarButtonItem = done
        
        self.navigationItem.hidesBackButton = true
        
        buildHostingViewController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hostingController = nil
    }
    
}

extension PostSignupCTAViewController {
    
    func buildHostingViewController() {
        let swiftUIView = AnyView(
            PostSignupCTAView()
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
    
    @objc func finishPairing () {
        presentableListener?.didFinishPairing()
    }
    
}
