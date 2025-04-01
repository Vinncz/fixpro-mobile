import Foundation
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
    func didScanAreaJoinCode (withDigestOf: AreaJoinCode)
    func didCancelScanningCodes()
}


/// Handles business logic and coordinates with other RIBs.
/// 
/// The `Interactor` class are responsible for handling business logic, and bridging between the `Presenter` (view) and `Router`.
final class CodeScanInteractor: PresentableInteractor<CodeScanPresentable>, CodeScanInteractable {
    
    weak var router: CodeScanRouting?
    weak var listener: CodeScanListener?
    
    private var viewModel: CodeScanViewModel? = CodeScanViewModel()
    
    override init (presenter: CodeScanPresentable) {
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
    
    /// Responsible in making sure the scanned code is valid before passing it on to ``PairInteractor``.
    func viewDidScanAreaJoinCode (withDigestOf stringReadFromQRCode: String) {
        switch AreaJoinCode.make(fromJsonString: stringReadFromQRCode) {
            case .success(let areaJoinCode):
                self.listener?.didScanAreaJoinCode(withDigestOf: areaJoinCode)
            case .failure(let error):
                switch error {
                    case .TYPE_MISMATCH, .MALFORMED:
                        self.viewModel?.scannerError = "Code was damaged."
                    default:
                        self.viewModel?.scannerError = "FixPro cannot recognize what code you scanned."
                }
        }
    }
    
    func viewDidRequestToBeDismissed () {
        self.viewModel = nil
        listener?.didCancelScanningCodes()
    }
    
}
