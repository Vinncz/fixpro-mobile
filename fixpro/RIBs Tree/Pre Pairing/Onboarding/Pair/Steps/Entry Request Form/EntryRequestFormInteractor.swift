import Foundation
import RIBs
import RxSwift


/// Collection of methods which ``EntryRequestFormInteractor`` can invoke, 
/// to perform something on its enclosing router (``EntryRequestFormRouter``).
/// 
/// Conformance to this protocol is **EXCLUSIVE** to ``EntryRequestFormRouter`` (internal use).
/// 
/// The `Routing` protocol bridges between ``EntryRequestFormInteractor`` and
/// ``EntryRequestFormRouter``, to enable business logic to manipulate the UI.
protocol EntryRequestFormRouting: ViewableRouting {}


/// Collection of methods which ``EntryRequestFormInteractor`` can invoke, 
/// to present data on ``EntryRequestFormViewController``.
///
/// Conformance to this protocol is **EXCLUSIVE** to ``EntryRequestFormViewController``.
///
/// The `Presentable` protocol bridges between ``EntryRequestFormInteractor`` and 
/// ``EntryRequestFormViewController``, to enable business logic to navigate the UI.
protocol EntryRequestFormPresentable: Presentable {
    var presentableListener: EntryRequestFormPresentableListener? { get set }
    func bind(viewModel: EntryRequestFormViewModel)
    func unbindViewModel()
}


/// Collection of methods which ``EntryRequestFormInteractor`` can invoke,
/// to perform logic on the parent's scope.
/// 
/// Conformance to this protocol is **EXCLUSIVE** to the parent's `Interactor` (external use).
/// 
/// The `Listener` protocol bridges between ``EntryRequestFormInteractor`` and its parent's `Interactor`.
/// 
/// By conforming to this, the parent RIB declares that it is willing
/// to receive and handle events coming from ``EntryRequestFormInteractor``.
protocol EntryRequestFormListener: AnyObject {
    func didFinishFillingOutTheFormAndSubmittedIt(authenticationCode: String?)
    func didChooseToGoBackToScanningCodes()
}


/// Handles business logic and coordinates with other RIBs.
/// 
/// The `Interactor` class are responsible for handling business logic, and bridging between the `Presenter` (view) and `Router`.
final class EntryRequestFormInteractor: PresentableInteractor<EntryRequestFormPresentable>, EntryRequestFormInteractable, @unchecked Sendable {
    
    
    /// The reference to the Router where self resides on.
    weak var router: EntryRequestFormRouting?
    
    
    /// The reference to parent's Interactor.
    /// 
    /// The word 'listener' is a convention used in RIBs, which refer to the preceding `Interactor` 
    /// who reacts to non-UI events from their descendants. (It 'listens' to them).
    weak var listener: EntryRequestFormListener?
    
    
    private var viewModel: EntryRequestFormViewModel? = EntryRequestFormViewModel()
    
    
    var identitySessionServiceProxy: any Proxy<FPIdentitySessionServicing>
    var pairingService: any FPPairingServicing
    
    
    init (presenter: EntryRequestFormPresentable, fields: [String], identitySessionServiceProxy: any Proxy<FPIdentitySessionServicing>, pairingService: any FPPairingServicing) {
        self.identitySessionServiceProxy = identitySessionServiceProxy
        self.pairingService = pairingService
        
        super.init(presenter: presenter)
        
        presenter.presentableListener = self
        configureViewModel(fields)
    }
    
    
}


extension EntryRequestFormInteractor {
    
    func configureViewModel(_ fields: [String]) {
        if let viewModel {
            viewModel.fieldsAndAnswers = Dictionary(uniqueKeysWithValues: fields.map{ ($0, "") })
            viewModel.didSubmit = { [weak self] answers in 
                self?.didFinishFillingOutTheFormAndRequestedToBeSubmitted(withAnswerOf: answers)
            }
            
            presenter.bind(viewModel: viewModel)
        }
    }
    
}


extension EntryRequestFormInteractor: EntryRequestFormPresentableListener {
    
    func didFinishFillingOutTheFormAndRequestedToBeSubmitted(withAnswerOf answers: [String : String]) {
        guard
            answers.allSatisfy({ a, b in 
                !b.isEmpty && !a.isEmpty 
                && !b.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !a.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            })
        else { 
            viewModel?.filloutValidationLabel = "All fields must be filled out."
            return
        }
        
        var continueOn = true
        presentLoadingAlert(
            on: router?.viewControllable.uiviewController,
            title: "Submitting your application..", 
            message: "Once approved, you can start using FixPro. Your progress is saved in case you cancel this submission.", 
            cancelButtonCTA: "Cancel", 
            delay: 20, 
            cancelAction: {
                continueOn = false
            }
        )
        
        Task {
            switch await self.pairingService.getApplicationId(bySubmittingTheFormFillout: answers) {
                case .success(let applicationId):
                    pairingService.applicationId = applicationId
                    switch pairingService.persists(applicationId, forKey: "applicationId") {
                        case .success: break
                        case .failure(let error):
                            self.viewModel?.filloutValidationLabel = error.localizedDescription
                            return
                    }
                    
                    guard let endpoint = pairingService.endpoint else {
                        FPLogger.log(tag: .critical, "Endpoint is missing between transition. This shouldn't happen.")
                        return
                    }
                    switch pairingService.persists(endpoint, forKey: "endpoint") {
                        case .success: break
                        case .failure(let error):
                            self.viewModel?.filloutValidationLabel = error.localizedDescription
                    }
                    
                    if continueOn {
                        var authenticationCode: String = ""
                        switch await pairingService.checkForApproval() {
                            case .success(let authCode): authenticationCode = authCode
                            case .failure: break
                        }
                        
                        await router?.viewControllable.uiviewController.dismiss(animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                            self?.listener?.didFinishFillingOutTheFormAndSubmittedIt(authenticationCode: authenticationCode)
                        }
                    }
                    
                case .failure(let error):
                    FPLogger.log(tag: .error, error)
                    viewModel?.filloutValidationLabel = error.localizedDescription
            }
        }
    }
    
    func didChooseToGoBackToScanningCodes() {
        listener?.didChooseToGoBackToScanningCodes()
    }
    
}
