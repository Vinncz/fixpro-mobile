import Foundation
import RIBs
import RxSwift
import SnapKit
import SwiftUI
import UIKit



/// Contract adhered to by ``AreaJoinningFormFillingInteractor``, listing the attributes and/or actions 
/// that ``AreaJoinningFormFillingViewController`` is allowed to access or invoke.
protocol AreaJoinningFormFillingPresentableListener: AnyObject {
    func didFinishFillingOutTheFormAndRequestedToBeSubmitted(withAnswerOf: [String: String])
    func didChooseToGoBackToScanningCodes()
}
 
 

/// The visible region of `AreaJoinningFormFillingRIB`.
final class AreaJoinningFormFillingViewController: UIViewController {
    
    
    /// Reference to ``AreaJoinningFormFillingInteractor``.
    weak var presentableListener: AreaJoinningFormFillingPresentableListener?
    
    
    /// Reference to ``AreaJoinningFormFillingSwiftUIViewModel``.
    weak var viewModel: AreaJoinningFormFillingSwiftUIViewModel?
    
    
    /// The SwiftUI view that is displayed by this view controller.
    var hostingController: UIHostingController<AreaJoinningFormFillingSwiftUIView>?
    
    
    /// Customization point that is invoked after self enters the view hierarchy.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.title = "Entry Request Form"
        
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(confirmBackNavigation))
        self.navigationItem.leftBarButtonItem = backButton
        
        let submit = UIBarButtonItem(title: "Submit", style: .done, target: self, action: #selector(submit))
        self.navigationItem.rightBarButtonItem = submit
        
        guard hostingController != nil else {
            buildHostingController()
            return
        }
    }
    
    
    /// Constructs an instance of ``AreaJoinningFormFillingSwiftUIView``, wraps them into `UIHostingController`,
    /// and sets it as the root view of this view controller.
    func buildHostingController() {
        guard let viewModel else { fatalError("ViewModel wasn't yet set.") }
        
        let swiftUIView = AreaJoinningFormFillingSwiftUIView(viewModel: viewModel)
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



/// Conformance to the ``AreaJoinningFormFillingViewControllable`` protocol.
/// Contains everything accessible or invokable by ``AreaJoinningFormFillingRouter``.
extension AreaJoinningFormFillingViewController: AreaJoinningFormFillingViewControllable {}



/// Conformance extension to the ``AreaJoinningFormFillingPresentable`` protocol.
/// Contains everything accessible or invokable by ``AreaJoinningFormFillingInteractor``.
extension AreaJoinningFormFillingViewController: AreaJoinningFormFillingPresentable {
    
    
    /// Binds the ``AreaJoinningFormFillingSwiftUIViewModel`` to the view controller.
    func bind(viewModel: AreaJoinningFormFillingSwiftUIViewModel) {
        self.viewModel = viewModel
    }
    
    
    /// Unbinds the ``AreaJoinningFormFillingSwiftUIViewModel`` from the view controller.
    func unbindViewModel() {
        self.viewModel = nil
    }
    
}
