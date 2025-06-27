import Foundation
import RIBs
import RxSwift
import VinUtility



/// Contract adhered to by ``AreaJoinningCodeScanningRouter``, listing the attributes and/or actions 
/// that ``AreaJoinningCodeScanningInteractor`` is allowed to access or invoke.
protocol AreaJoinningCodeScanningRouting: ViewableRouting {}



/// Contract adhered to by ``AreaJoinningCodeScanningViewController``, listing the attributes and/or actions
/// that ``AreaJoinningCodeScanningInteractor`` is allowed to access or invoke.
protocol AreaJoinningCodeScanningPresentable: Presentable {
    
    
    /// Reference to ``AreaJoinningCodeScanningInteractor``.
    var presentableListener: AreaJoinningCodeScanningPresentableListener? { get set }
    
    
    /// Binds the view model to the view.
    func bind(viewModel: AreaJoinningCodeScanningSwiftUIViewModel)
    
    
    /// Unbinds the view model from the view.
    func unbindViewModel()
    
}



/// Contract adhered to by the Interactor of `AreaJoinningCodeScanningRIB`'s parent, listing the attributes and/or actions
/// that ``AreaJoinningCodeScanningInteractor`` is allowed to access or invoke.
protocol AreaJoinningCodeScanningListener: AnyObject {
    func didContactAreaForTheirEntryForm(andCameUpWithTheFollowingFields: [String])
    func exitScanningCodes()
}



/// The functionality centre of `AreaJoinningCodeScanningRIB`, where flow, communication, and coordination
/// are determined and initiated from.
final class AreaJoinningCodeScanningInteractor: PresentableInteractor<AreaJoinningCodeScanningPresentable>, AreaJoinningCodeScanningInteractable {
    
    
    /// Reference to ``AreaJoinningCodeScanningRouter``.
    weak var router: AreaJoinningCodeScanningRouting?
    
    
    /// Reference to this RIB's parent's Interactor.
    weak var listener: AreaJoinningCodeScanningListener?
    
    
    /// Reference to the component of this RIB.
    var component: AreaJoinningCodeScanningComponent
    
    
    /// Bridge to the ``AreaJoinningCodeScanningSwiftUIVIew``.
    private var viewModel = AreaJoinningCodeScanningSwiftUIViewModel()
    
    
    /// Constructs an instance of ``AreaJoinningCodeScanningInteractor``.
    /// - Parameter component: The component of this RIB.
    init(component: AreaJoinningCodeScanningComponent) {
        self.component = component
        let presenter = component.areaJoinningCodeScanningViewController
        
        super.init(presenter: presenter)
        
        presenter.presentableListener = self
    }
    
    
    /// Customization point that is invoked after self becomes active.
    override func didBecomeActive() {
        super.didBecomeActive()
        configureViewModel()
    }
    
    
    /// Customization point that is invoked before self is fully detached.
    override func willResignActive() {
        super.willResignActive()
    }
    
    
    /// Configures the view model.
    private func configureViewModel() {
        viewModel.didScan = { [weak self] digest in
            self?.viewDidScanAreaJoinCode(withDigestOf: digest)
        }
        
        presenter.bind(viewModel: self.viewModel)
    }
    
}



/// Conformance to the ``AreaJoinningCodeScanningPresentableListener`` protocol.
/// Contains everything accessible or invokable by ``AreaJoinningCodeScanningViewController``.
extension AreaJoinningCodeScanningInteractor: AreaJoinningCodeScanningPresentableListener, @unchecked Sendable {
    
    
    /// Responsible in making sure the scanned code is valid before requesting ``PairInteractor`` to move to the next screen.
    func viewDidScanAreaJoinCode(withDigestOf stringReadFromQRCode: String) {
        switch AreaJoinCode.make(fromJsonString: stringReadFromQRCode) {
        case .success(let areaJoinCode):
            var continueOn = true
            
            // Step 1 -- Stop scanning
            viewModel.isScanning = false
            
            
            // Step 2 -- Show spinner
            Task {
            let topMostViewController = await topMostViewController()
            await VUPresentLoadingAlert(
                on: topMostViewController,
                title: "Requesting Entry..", 
                message: "This action shouldn't take more than 15 seconds.", 
                cancelButtonCTA: "Cancel", 
                delay: 10, 
                cancelAction: { [weak self] in
                    continueOn = false
                    self?.viewModel.isScanning = true
                    self?.viewModel.scannerError = ""
                }
            )
            
            
            // Step 3 -- Make first contact
                do {
                    let firstContactAttempt = try await FPOnboardingService.makeFirstContactWithArea(areaJoinCode: areaJoinCode).get()
                    component.onboardingServiceProxy.back(with: firstContactAttempt.onboardingService)
                    
                    if continueOn {
                        await topMostViewController?.dismiss(animated: true)
                        self.listener?.didContactAreaForTheirEntryForm(andCameUpWithTheFollowingFields: firstContactAttempt.fields)
                    }
                    
                } catch let error as FPError {
                    VULogger.log(tag: .error, error)
                    
                    viewModel.scannerError = 
                       """
                       **Unable to contact the Area, possibly due to them being offline.**
                       
                       You can try again later or contact them directly.\
                        `\(error.domain)Error-\(error.code)`.
                       """
                    
                }
            }
            
        case .failure(let error):
            switch error {
            case .MALFORMED:
                self.viewModel.scannerError = 
                   """
                   **Code may be damaged or isn't formatted properly.**
                   
                   It probably wasn't made by a FixPro application.\ 
                    `\(error.domain)Error-\(error.code)`
                   """
                    
            case .TYPE_MISMATCH:
                self.viewModel.scannerError = 
                   """
                   **Code may be using a newer standard.**
                   
                   This version of FixPro is unable to process it.\ 
                    `\(error.domain)Error-\(error.code)`
                   """
                    
            default:
                self.viewModel.scannerError = 
                   """
                   **Cannot comprehend this code.**
                   
                   Try scanning another code or alternatively, ask for a new one.\
                    `\(error.domain)Error-\(error.code)`
                   """
            }
        }
    }
    
    func viewDidRequestToBeDismissed () {
        listener?.exitScanningCodes()
    }
    
}
