import Foundation
import UIKit
import RIBs
import RxSwift


/// Collection of methods which ``CodeScanInteractor`` can invoke, 
/// to perform something on its enclosing router (``CodeScanRouter``).
/// 
/// Conformance to this protocol is **EXCLUSIVE** to ``CodeScanRouter`` (internal use).
/// 
/// The `Routing` protocol bridges between ``CodeScanInteractor`` and
/// ``CodeScanRouter``, to enable business logic to manipulate the UI.
protocol CodeScanRouting: ViewableRouting {}


/// Collection of methods which ``CodeScanInteractor`` can invoke, 
/// to present data on ``CodeScanViewController``.
///
/// Conformance to this protocol is **EXCLUSIVE** to ``CodeScanViewController``.
///
/// The `Presentable` protocol bridges between ``CodeScanInteractor`` and 
/// ``CodeScanViewController``, to enable business logic to navigate the UI.
protocol CodeScanPresentable: Presentable {
    var presentableListener: CodeScanPresentableListener? { get set }
    func bind(viewModel: CodeScanViewModel)
    func unbindViewModel()
}


/// Collection of methods which ``CodeScanInteractor`` can invoke,
/// to perform logic on the parent's scope.
/// 
/// Conformance to this protocol is **EXCLUSIVE** to the parent's `Interactor` (external use).
/// 
/// The `Listener` protocol bridges between ``CodeScanInteractor`` and its parent's `Interactor`.
/// 
/// By conforming to this, the parent RIB declares that it is willing
/// to receive and handle events coming from ``CodeScanInteractor``.
protocol CodeScanListener: AnyObject {
    func didContactAreaForTheirEntryForm(andCameUpWithTheFollowingFields: [String])
    func exitScanningCodes()
}


/// Handles business logic and coordinates with other RIBs.
/// 
/// The `Interactor` class are responsible for handling business logic, and bridging between the `Presenter` (view) and `Router`.
final class CodeScanInteractor: PresentableInteractor<CodeScanPresentable>, CodeScanInteractable, @unchecked Sendable {
    
    weak var router: CodeScanRouting?
    weak var listener: CodeScanListener?
    
    private var viewModel: CodeScanViewModel? = CodeScanViewModel()
    
    var identitySessionServiceProxy: any Proxy<FPIdentitySessionServicing>
    var pairingService: any FPPairingServicing
    
    init (presenter: CodeScanPresentable, identitySessionServiceProxy: any Proxy<FPIdentitySessionServicing>, pairingService: any FPPairingServicing) {
        self.identitySessionServiceProxy = identitySessionServiceProxy
        self.pairingService = pairingService
        
        super.init(presenter: presenter)
        
        presenter.presentableListener = self
    }
    
    
    override func didBecomeActive() {
        configureViewModel()
        if let viewModel {
            presenter.bind(viewModel: viewModel)
        }
    }
    
}

extension CodeScanInteractor {
    
    func configureViewModel () {
        if let viewModel {
            viewModel.didScan = { [weak self] digest in
                self?.viewDidScanAreaJoinCode(withDigestOf: digest)
            }
        }
    }
    
}

extension CodeScanInteractor: CodeScanPresentableListener {
    
    /// Responsible in making sure the scanned code is valid before requesting ``PairInteractor`` to move to the next screen.
    func viewDidScanAreaJoinCode (withDigestOf stringReadFromQRCode: String) {
        switch AreaJoinCode.make(fromJsonString: stringReadFromQRCode) {
            case .success(let areaJoinCode):
                var continueOn = true
                viewModel?.isScanning = false
                presentLoadingAlert(
                    on: router?.viewControllable.uiviewController,
                    title: "Requesting Entry..", 
                    message: "This action shouldn't take more than 15 seconds.", 
                    cancelButtonCTA: "Cancel", 
                    delay: 10, 
                    cancelAction: { [weak self] in
                        continueOn = false
                        self?.viewModel?.isScanning = true
                        self?.viewModel?.scannerError = ""
                    }
                )
                
                Task {
                    pairingService.endpoint = areaJoinCode.endpoint
                    pairingService.referralTrackingIdentifier = areaJoinCode.referralTrackingIdentifier
                    
                    switch await pairingService.getFormFieldsAndNonce() {
                        case .success(let fieldsAndNonce):
                            pairingService.nonce = fieldsAndNonce.nonce
                            if continueOn {
                                await router?.viewControllable.uiviewController.dismiss(animated: true)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                                    self?.listener?.didContactAreaForTheirEntryForm(andCameUpWithTheFollowingFields: fieldsAndNonce.fields)
                                }
                            }
                            
                        case .failure(let error):
                            FPLogger.log(tag: .error, error)
                            viewModel?.scannerError = "**Unable to contact the Area, possibly due to them being offline.**\n\nYou can try again later, or contact them directly."
                    }
                }
                
            case .failure(let error):
                switch error {
                    case .MALFORMED:
                        self.viewModel?.scannerError = "**Code may be damaged or isn't formatted properly.**\n\nIt probably wasn't made by a FixPro application."
                    case .TYPE_MISMATCH:
                        self.viewModel?.scannerError = "**Code may be using a newer standard.**\n\nThis version of FixPro is unable to process it."
                    default:
                        self.viewModel?.scannerError = "**Cannot comprehend this code.**\n\nTry scanning another code or alternatively, ask for a new one."
                }
        }
    }
    
    func viewDidRequestToBeDismissed () {
        self.viewModel = nil
        listener?.exitScanningCodes()
    }
    
}
