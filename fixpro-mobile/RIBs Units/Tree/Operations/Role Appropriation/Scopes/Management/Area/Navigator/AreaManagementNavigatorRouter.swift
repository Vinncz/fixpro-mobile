import RIBs
import UIKit
import VinUtility



/// Contract adhered to by ``AreaManagementNavigatorInteractor``, listing the attributes and/or actions 
/// that ``AreaManagementNavigatorRouter`` is allowed to access or invoke.
/// 
/// Conform this `Interactable` protocol with this RIB's children's `Listener` protocols.
protocol AreaManagementNavigatorInteractable: Interactable, 
                                                AreaManagementListener, 
                                                ManageMembershipsListener, 
                                                    ApplicantDetailListener, 
                                                    MemberDetailListener,
                                                IssueTypesRegistrarListener, 
                                                ManageSLAListener, 
                                                StatisticsAndReportsListener {
    
    
    /// Reference to ``AreaManagementNavigatorRouter``.
    var router: AreaManagementNavigatorRouting? { get set }
    
    
    /// Reference to this RIB's parent's Interactor.
    var listener: AreaManagementNavigatorListener? { get set }
    
}



/// Contract adhered to by ``AreaManagementNavigatorViewController``, listing the attributes and/or actions
/// that ``AreaManagementNavigatorRouter`` is allowed to access or invoke.
protocol AreaManagementNavigatorViewControllable: ViewControllable {
    
    
    /// Pushes the given `ViewControllable` onto the navigation stack.
    /// - Parameter viewControllable: The `ViewControllable` to be pushed.
    /// - Parameter animated: A Boolean value that indicates whether the transition should be animated.
    func push(_ viewControllable: ViewControllable, animated: Bool)
    
    
    /// Pops the top view controller off the navigation stack.
    /// - Parameter animated: A Boolean value that indicates whether the transition should be animated.
    /// - Returns: An optional view controller that was popped.
    @discardableResult func pop(animated: Bool) -> UIViewController?
    
    
    /// Pops all view controllers on the navigation stack until the root view controller is at the top.
    /// - Parameter animated: A Boolean value that indicates whether the transition should be animated.
    /// - Note: This method does not remove the root view controller from the navigation stack.
    /// - Returns: An optional array of view controllers that were popped.
    @discardableResult func popToRoot(animated: Bool) -> [UIViewController]?
    
    
    /// Sets the view controllers of the navigation stack.
    /// - Parameter viewControllables: An array of `ViewControllable` to be set as the new view controllers.
    /// - Parameter animated: A Boolean value that indicates whether the transition should be animated.
    func set(_ viewControllables: [ViewControllable], animated: Bool)
    
}



/// The attachment point of `AreaManagementNavigatorRIB`.
final class AreaManagementNavigatorRouter: ViewableRouter<AreaManagementNavigatorInteractable, AreaManagementNavigatorViewControllable> {
    
    
    var areaManagementBuilder: AreaManagementBuildable
    var areaManagementRouter: AreaManagementRouting?
    
    var manageMembershipsBuilder: ManageMembershipsBuildable
    var manageMembershipsRouter: ManageMembershipsRouting?
    
        var applicantDetailBuilder: ApplicantDetailBuildable
        var applicantDetailRouter: ApplicantDetailRouting?
        
        var memberDetailBuilder: MemberDetailBuildable
        var memberDetailRouter: MemberDetailRouting?
    
    var issueTypesRegistrarBuilder: IssueTypesRegistrarBuildable
    var issueTypesRegistrarRouter: IssueTypesRegistrarRouting?
    
    var manageSLABuilder: ManageSLABuildable
    var manageSLARouter: ManageSLARouting?
    
    var statisticsAndReportsBuilder: StatisticsAndReportsBuildable
    var statisticsAndReportsRouter: StatisticsAndReportsRouting?
    
    
    /// Constructs an instance of ``AreaManagementNavigatorRouter``.
    /// - Parameter interactor: The interactor for this RIB.
    /// - Parameter viewController: The view controller for this RIB.
    init(interactor: AreaManagementNavigatorInteractable, 
         viewController: AreaManagementNavigatorViewControllable, 
         areaManagementBuilder: AreaManagementBuildable, 
         manageMembershipsBuilder: ManageMembershipsBuildable,
         applicantDetailBuilder: ApplicantDetailBuildable,
         memberDetailBuilder: MemberDetailBuildable,
         issueTypesRegistrarBuilder: IssueTypesRegistrarBuildable,
         manageSLABuilder: ManageSLABuildable,
         statisticsAndReportsBuilder: StatisticsAndReportsBuildable
    ) {
        self.areaManagementBuilder = areaManagementBuilder
        self.manageMembershipsBuilder = manageMembershipsBuilder
            self.applicantDetailBuilder = applicantDetailBuilder
            self.memberDetailBuilder = memberDetailBuilder
        self.issueTypesRegistrarBuilder = issueTypesRegistrarBuilder
        self.manageSLABuilder = manageSLABuilder
        self.statisticsAndReportsBuilder = statisticsAndReportsBuilder
        
        super.init(interactor: interactor, viewController: viewController)
        
        interactor.router = self
    }
    
    
    /// Customization point that is invoked after self becomes active.
    override func didLoad() {
        loadManagementView()
    }
    
}



extension AreaManagementNavigatorRouter {
    
    
    func loadManagementView() {
        let router = areaManagementBuilder.build(withListener: interactor)
        self.areaManagementRouter = router
        
        self.attachChild(router)
        self.viewController.push(router.viewControllable, animated: false)
    }
    
}



/// Conformance extension to the ``AreaManagementNavigatorRouting`` protocol.
/// Contains everything accessible or invokable by ``AreaManagementNavigatorInteractor``.
extension AreaManagementNavigatorRouter: AreaManagementNavigatorRouting {
    
    
    func navigateToManageMemberships() {
        let router = manageMembershipsBuilder.build(withListener: interactor)
        self.manageMembershipsRouter = router
        
        self.attachChild(router)
        self.viewController.push(router.viewControllable, animated: true)
    }
    
            func navigateToApplicantDetail(_ applicant: FPEntryApplication) {
                let router = applicantDetailBuilder.build(withListener: interactor, applicant: applicant)
                self.applicantDetailRouter = router
                
                self.attachChild(router)
                self.viewController.push(router.viewControllable, animated: true)
            }
            
            func navigateToMemberDetail(_ member: FPPerson) {
                let router = memberDetailBuilder.build(withListener: interactor, member: member)
                self.memberDetailRouter = router
                
                self.attachChild(router)
                self.viewController.push(router.viewControllable, animated: true)
            }
    
    
    func navigateToIssueTypesRegistrar() {
        let router = issueTypesRegistrarBuilder.build(withListener: interactor)
        self.issueTypesRegistrarRouter = router
        
        self.attachChild(router)
        self.viewController.push(router.viewControllable, animated: true)
    }
    
    
    func navigateToManageSLA() {
        let router = manageSLABuilder.build(withListener: interactor)
        self.manageSLARouter = router
        
        self.attachChild(router)
        self.viewController.push(router.viewControllable, animated: true)
    }
    
    
    func navigateToStatisticsAndReports() {
        let router = statisticsAndReportsBuilder.build(withListener: interactor)
        self.statisticsAndReportsRouter = router
        
        self.attachChild(router)
        self.viewController.push(router.viewControllable, animated: true)
    }
    
}



/// Extension for backward navigation.
extension AreaManagementNavigatorRouter {
    
    
    func respondToNavigateBack(from origin: UIViewController) {
        if origin === manageMembershipsRouter?.viewControllable.uiviewController {
            VULogger.log("detachManageMemberships")
            detachManageMemberships()
        } else if origin === applicantDetailRouter?.viewControllable.uiviewController {
            VULogger.log("detachApplicantDetail")
            detachApplicantDetail()
        } else if origin === memberDetailRouter?.viewControllable.uiviewController {
            VULogger.log("detachMemberDetail")
            detachMemberDetail()
        } else if origin === issueTypesRegistrarRouter?.viewControllable.uiviewController {
            VULogger.log("detachIssueTypesRegistrar")
            detachIssueTypesRegistrar()
        } else if origin === manageSLARouter?.viewControllable.uiviewController {
            VULogger.log("detachManageSLA")
            detachManageSLA()
        } else if origin === statisticsAndReportsRouter?.viewControllable.uiviewController {
            VULogger.log("detachStatisticsAndReports")
            detachStatisticsAndReports()
        }        
    }
    
    
    func toRoot() {
        viewController.popToRoot(animated: true)
        detachManageMemberships()
        detachIssueTypesRegistrar()
        detachManageSLA()
        detachStatisticsAndReports()
    }
    
    
    /// Cleanses the view hierarchy of any `ViewControllable` instances this RIB may have added.
    func cleanupViews() {
        viewController.set([], animated: false)
        detachAreaManagement()
        detachManageMemberships()
        detachIssueTypesRegistrar()
        detachManageSLA()
        detachStatisticsAndReports()
    }
    
}



/// Extension for RIBs detachments.
extension AreaManagementNavigatorRouter {
    
    
    func didRemove(applicant: FPEntryApplication) {
        manageMembershipsRouter?.didRemove(applicant: applicant)
        viewController.pop(animated: true)
    }
    
    
    func didRemove(member: FPPerson) {
        manageMembershipsRouter?.didRemove(member: member)
        viewController.pop(animated: true)
    }
    
}



/// Extension for RIBs detachments.
extension AreaManagementNavigatorRouter {
    
    
    func detachAreaManagement() {
        if let areaManagementRouter {
            detachChild(areaManagementRouter)
            self.areaManagementRouter = nil
        }
    }
    
    
    func detachManageMemberships() {
        if let manageMembershipsRouter {
            detachChild(manageMembershipsRouter)
            self.manageMembershipsRouter = nil
        }
    }
    func detachApplicantDetail() {
        if let applicantDetailRouter {
            detachChild(applicantDetailRouter)
            self.applicantDetailRouter = nil
        }
    }
    func detachMemberDetail() {
        if let memberDetailRouter {
            detachChild(memberDetailRouter)
            self.memberDetailRouter = nil
        }
    }
    
    
    func detachIssueTypesRegistrar() {
        if let issueTypesRegistrarRouter {
            detachChild(issueTypesRegistrarRouter)
            self.issueTypesRegistrarRouter = nil
        }
    }
    
    
    func detachManageSLA() {
        if let manageSLARouter {
            detachChild(manageSLARouter)
            self.manageSLARouter = nil
        }
    }
    
    
    func detachStatisticsAndReports() {
        if let statisticsAndReportsRouter {
            detachChild(statisticsAndReportsRouter)
            self.statisticsAndReportsRouter = nil
        }
    }
    
}
