import Foundation
import VinUtility



/// Set of requirements for a service that helps in retaining state on the onboarding process.
protocol FPOnboardingServicing: VUStatefulServicing {
    
    
    // MARK: -- Discovery and first contact
    
    /// The name of the area issuing the `Area Join Code`.
    var areaName: String { get }
    
    
    /// The API address of the Area's FixPro Backend.
    var networkingClient: FPNetworkingClient? { get set }
    
    
    /// The unique code per qr-code of `Area Join Code`.
    var referralTrackingIdentifier: String? { get }
    
    
    
    // MARK: -- Form fillout & submission
    
    /// Number used once, for form submission purposes. Expires in a few minutes.
    var nonce: String? { get }
    
    
    
    // MARK: -- Post form submission
    
    /// A unique string, representing the receipt that you've had applied to join an Area.
    var applicationId: String? { get set }
    
    
    /// The point in time when the application was submitted.
    var applicationSubmissionDate: Date? { get set }
    
    
    /// The point in time, issued by Area's `FixPro Backend`, where we can assume the application has been automatically rejected.
    var applicationIdExpiryDate: Date? { get set }
    
    
    
    // MARK: -- Communications with FixPro Backend
    
    /// 
    static func makeFirstContactWithArea(areaJoinCode: AreaJoinCode) async -> Result<(onboardingService: FPOnboardingServicing, fields: [String]), FPError>
    
    
    /// 
    func submitApplicationForm(with fields: [String: String]) async -> Result<(applicationId: String, applicationExpiryDate: Date), FPError>
    
    
    /// 
    func checkApplicationStatus() async -> Result<String, FPError>
    
    
    /// 
    @discardableResult func cancelApplication() -> Result<Void, FPError>
    
    
    // MARK: -- Utils
    
    func deepCopy() -> FPOnboardingServicing
    
}
