import RIBs
import RxSwift
import SwiftUI
import UIKit


/// Collection of methods which ``EntryRequestFormViewController`` can invoke, to perform business logic.
///
/// The `PresentableListener` protocol is responsible to bridge UI events to business logic.  
/// When an interaction with the UI is performed (e.g., pressed a button), ``EntryRequestFormViewController`` **MAY**
/// call method(s) declared here to notify the `Interactor` to perform any associated logics.
///
/// Conformance of this protocol is **EXCLUSIVE** to ``EntryRequestFormInteractor`` (internal use).
/// ``EntryRequestFormViewController``, in turn, can invoke methods declared in this protocol 
/// via its ``EntryRequestFormViewController/presentableListener`` attribute.
protocol EntryRequestFormPresentableListener: AnyObject {
    func didFinishFillingOutTheFormAndRequestedToBeSubmitted(withAnswerOf: [String: String])
    func didChooseToGoBackToScanningCodes()
}


/// The UI of `EntryRequestFormRIB`.
final class EntryRequestFormViewController: UIViewController, EntryRequestFormPresentable, EntryRequestFormViewControllable {
    
    
    /// The reference to ``EntryRequestFormInteractor``.
    /// 
    /// The word 'presentableListener' is a convention used in RIBs, which refer to the `Interactor`
    /// who reacts to UI events from their descendants. (It 'listens' to them).
    weak var presentableListener: EntryRequestFormPresentableListener?
    var viewModel: EntryRequestFormViewModel? = nil
    var hostingController: UIHostingController<AnyView>? = nil
    
    
    override func viewDidLoad () {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.title = "Entry Request Form"
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(confirmBackNavigation))
        self.navigationItem.leftBarButtonItem = backButton
        
        let submit = UIBarButtonItem(title: "Submit", style: .done, target: self, action: #selector(submit))
        self.navigationItem.rightBarButtonItem = submit
        
        buildEntryRequestFormView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hostingController = nil
    }
    
    
    func bind(viewModel: EntryRequestFormViewModel) {
        self.viewModel = viewModel
    }
    
    func unbindViewModel() {
        self.viewModel = nil
    }
    
}


extension EntryRequestFormViewController {
    
    func buildEntryRequestFormView() {
        guard let viewModel else { return }
        
        let swiftUIView = AnyView(
            EntryRequestFormView(viewModel: viewModel)
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
    
}


extension EntryRequestFormViewController {
    
    @objc func confirmBackNavigation() {
        let alert = UIAlertController (
            title: "Are you sure?",
            message: "Going back will reset your progress.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes, go back", style: .destructive, handler: { [weak self] _ in
            self?.presentableListener?.didChooseToGoBackToScanningCodes()
        }))
        
        present(alert, animated: true)
    }
    
    @objc func submit () {
        presentableListener?.didFinishFillingOutTheFormAndRequestedToBeSubmitted(withAnswerOf: viewModel?.fieldsAndAnswers ?? [:])
    }
    
}
