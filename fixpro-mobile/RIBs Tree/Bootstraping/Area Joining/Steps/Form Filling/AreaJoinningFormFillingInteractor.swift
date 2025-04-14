import Foundation
import RIBs
import RxSwift
import VinUtility



/// Contract adhered to by ``AreaJoinningFormFillingRouter``, listing the attributes and/or actions 
/// that ``AreaJoinningFormFillingInteractor`` is allowed to access or invoke.
protocol AreaJoinningFormFillingRouting: ViewableRouting {}



/// Contract adhered to by ``AreaJoinningFormFillingViewController``, listing the attributes and/or actions
/// that ``AreaJoinningFormFillingInteractor`` is allowed to access or invoke.
protocol AreaJoinningFormFillingPresentable: Presentable {
    
    
    /// Reference to ``AreaJoinningFormFillingInteractor``.
    var presentableListener: AreaJoinningFormFillingPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: AreaJoinningFormFillingSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `AreaJoinningFormFillingRIB`'s parent, listing the attributes and/or actions
/// that ``AreaJoinningFormFillingInteractor`` is allowed to access or invoke.
protocol AreaJoinningFormFillingListener: AnyObject {
    func didFinishFillingOutTheFormAndSubmittedItWhileAlsoSavedPairingInformationToPairingService()
    func didChooseToGoBackToScanningCodes()
}



/// The functionality centre of `AreaJoinningFormFillingRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class AreaJoinningFormFillingInteractor: PresentableInteractor<AreaJoinningFormFillingPresentable>, AreaJoinningFormFillingInteractable {
    
    
    /// Reference to ``AreaJoinningFormFillingRouter``.
    weak var router: AreaJoinningFormFillingRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: AreaJoinningFormFillingListener?
    
    
    /// Reference to the component of this RIB.
    var component: AreaJoinningFormFillingComponent
    
    
    /// Bridge to the ``AreaJoinningFormFillingSwiftUIVIew``.
    private var viewModel = AreaJoinningFormFillingSwiftUIViewModel()
    
    
    /// Constructs an instance of ``AreaJoinningFormFillingInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: AreaJoinningFormFillingComponent, fields: [String]) {
        self.component = component
        let presenter = component.areaJoinningFormFillingViewController
        super.init(presenter: presenter)
        
        presenter.presentableListener = self
        configureViewModel(fields: fields)
    }
    
    
    /// Configures the view model.
    private func configureViewModel(fields: [String]) {
        viewModel.fieldsAndAnswers = Dictionary(uniqueKeysWithValues: fields.map{ ($0, "") })
        viewModel.didSubmit = { [weak self] answers in 
            self?.didFinishFillingOutTheFormAndRequestedToBeSubmitted(withAnswerOf: answers)
        }
        
        presenter.bind(viewModel: self.viewModel)
    }
    
}



/// Conformance to the ``AreaJoinningFormFillingPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``AreaJoinningFormFillingViewController``.
extension AreaJoinningFormFillingInteractor: AreaJoinningFormFillingPresentableListener, @unchecked Sendable {
    
    
    func didFinishFillingOutTheFormAndRequestedToBeSubmitted(withAnswerOf answers: [String : String]) {
        
        // Step 1 -- Validate answer
        guard
            answers.allSatisfy({ a, b in 
                !b.isEmpty && !a.isEmpty 
                && !b.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !a.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            })
        else { 
            viewModel.filloutValidationLabel = "All fields must be filled out."
            return
        }
        
        var continueOn = true
        
        
        // Step 2 -- Show spinner
        VUPresentLoadingAlert(
            on: router?.viewControllable.uiviewController,
            title: "Submitting your application..", 
            message: "Once approved, you can start using FixPro. Your progress is saved in case you cancel this submission.", 
            cancelButtonCTA: "Cancel", 
            delay: 20, 
            cancelAction: {
                continueOn = false
            }
        )
        
        
        // Step 3 -- Perform admin jobs
        Task {
            
            
            // Step 4 -- Make network call
            switch await self.component.bootstraperService.submitApplicationForm(with: answers) {
                case .success(let tuple):
                    
                    
                    // Step 5 -- Note the response
                    self.component.bootstraperService.applicationId = tuple.applicationId
                    self.component.bootstraperService.applicationIdExpiryDate = tuple.applicationExpiryDate
                    self.component.bootstraperService.applicationSubmissionDate = .now
                    
                    
                    // Step 6 -- Make sure any previously noted things have not dissapeared for any reason.
                    guard 
                        let endpoint = self.component.bootstraperService.endpoint,
                        let areaName = self.component.bootstraperService.areaName,
                        let applicationSubmissionDate = self.component.bootstraperService.applicationSubmissionDate
                    else {
                        VULogger.log(tag: .critical, "Some critical information is missing between transition. This shouldn't happen.")
                        viewModel.filloutValidationLabel = "An incoverable error occured. The solution is to exit this form and try redoing it all over."
                        return
                    }
                    
                    
                    // Step 7 -- Should network calls take longer than expected, user CAN cancel the operation.
                    //           When it happens, do not continue no more.
                    if continueOn {
                        
                        
                        // Step 8 -- Persist important information before continuing
                        self.component.bootstrapperServiceMementoAgent.takeSnapshot(tag: nil)
                        
                        
                        // Step 9 -- Dismiss the spinner
                        await router?.viewControllable.uiviewController.dismiss(animated: true)
                        
                        
                        // Step 10 -- Transition to next step (CTA).
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                            self?.listener?.didFinishFillingOutTheFormAndSubmittedItWhileAlsoSavedPairingInformationToPairingService()
                        }
                    }
                    
                case .failure(let error):
                    VULogger.log(tag: .error, error)
                    viewModel.filloutValidationLabel = error.localizedDescription
            }
        }
    }
    
    func didChooseToGoBackToScanningCodes() {
        listener?.didChooseToGoBackToScanningCodes()
    }
    
}
