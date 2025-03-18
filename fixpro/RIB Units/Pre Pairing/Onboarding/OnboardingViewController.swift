import RIBs
import SwiftUI
import RxSwift
import SnapKit
import UIKit

/// Collection of methods which ``OnboardingViewController`` can invoke, to perform business logic.
///
/// The `PresentableListener` protocol is responsible to bridge UI events to business logic.  
/// When an interaction with the UI is performed (e.g., pressed a button), ``OnboardingViewController`` **MAY**
/// call method(s) declared here to notify the `Interactor` to perform any associated logics.
///
/// Conformance of this protocol is **EXCLUSIVE** to ``OnboardingInteractor`` (internal use).
/// ``OnboardingViewController``, in turn, can invoke methods declared in this protocol 
/// via its ``OnboardingViewController/presentableListener`` attribute.
protocol OnboardingPresentableListener: AnyObject {
    func quePairingFlow()
    func queInformationFlow()
}


/// The UI of `OnboardingRIB`.
final class OnboardingViewController: UIViewController, OnboardingPresentable {
    
    
    /// The reference to ``OnboardingInteractor``.
    /// 
    /// The word 'presentableListener' is a convention used in RIBs, which refer to the `Interactor`
    /// who reacts to UI events from their descendants. (It 'listens' to them).
    weak var presentableListener: OnboardingPresentableListener?
    
    
    /// The reference to the flow that is presented.
    weak var presentedFlow: ViewControllable? = nil
    
    
    var hostingController: UIHostingController<AnyView>? = nil


    override func viewDidLoad() {
        guard hostingController != nil else {
            buildHostingController()
            return
        }
    }
    
}

extension OnboardingViewController: OnboardingViewControllable {
    
    func present(_ flow: ViewControllable) {
        self.presentedFlow = flow
        self.present(flow.uiviewController, animated: true)
    }
    
    func dismiss(_ flow: any ViewControllable) {
        if self.presentedFlow === flow {
            self.dismiss(animated: true)
            self.presentedFlow = nil
        }
    }
    
}

extension OnboardingViewController {
    
    func buildHostingController() {
        let swiftUIView = AnyView(OnboardingView (
            onButtonClick: { [weak self] in
                self?.presentableListener?.quePairingFlow()
            },
            onInfoClick: { [weak self] in 
                self?.presentableListener?.queInformationFlow()
            }
        ))
        
        let featureViewController = UIHostingController(rootView: swiftUIView)
        
        self.addChild(featureViewController)
        self.view.addSubview(featureViewController.view)   
        
        featureViewController.view.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        featureViewController.didMove(toParent: self)
        self.hostingController = featureViewController
    }
    
    @objc func didTapPairButton() {
        guard presentedFlow == nil else { return }
        presentableListener?.quePairingFlow()
    }
    
}
