import RIBs
import RxSwift
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.title = "Submitted successfully"
        
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(finishPairing))
        self.navigationItem.rightBarButtonItem = done
        
        self.navigationItem.hidesBackButton = true
    }
    
}

extension PostSignupCTAViewController {
    
    @objc func finishPairing () {
        presentableListener?.didFinishPairing()
    }
    
}
