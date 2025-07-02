import Foundation
import Observation



/// Bridges between ``AreaManagementSwiftUIView`` and the ``AreaManagementInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class AreaManagementSwiftUIViewModel {
    
    
    var areaName: String?
    
    
    var areaJoinCodeEndpoint: String?
    
    
    var joinPolicy: FPAreaJoinPolicy?
    
    
    var didUpdateJoinPolicy: ((FPAreaJoinPolicy)->Void)?
    
    
    var routeToManageMemberships: (()->Void)?
    
    
    var routeToStatisticsAndReports: (()->Void)?
    
    
    var routeToIssueTypesRegistrar: (()->Void)?
    
    
    var routeToManageSLA: (()->Void)?
    
    
    var didIntendToRefresh: (()->Void)?
    
    
    var ticketCount: Int?
    
}
