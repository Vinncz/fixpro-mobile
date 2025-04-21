import CryptoKit
import Foundation
import VinUtility



/// 
class FPOnboardingService: FPOnboardingServicing {
    
    
    // MARK: -- Discovery and first contact
    
    /// The name of the area issuing the `Area Join Code`.
    var areaName: String
    
    
    /// The networking client to contact the Area.
    var networkingClient: FPNetworkingClient?
    
    
    /// The unique identifier per qr-code of an `Area Join Code`.
    var referralTrackingIdentifier: String?
    
    
    
    // MARK: -- Form fillout & submission
    
    /// Number used once for form submission purposes. Expires in a few minutes time.
    var nonce: String?
    
    
    
    // MARK: -- Post form submission
    
    /// A unique string, representing the receipt that you've had applied to join an Area.
    var applicationId: String?
    
    
    /// The point in time when the application was submitted.
    var applicationSubmissionDate: Date?
    
    
    /// The point in time, issued by Area's `Backend`, where we can assume the application has been automatically rejected.
    var applicationIdExpiryDate: Date?
    
    
    private init(areaName: String, networkingClient: FPNetworkingClient?, referralTrackingIdentifier: String?, nonce: String?, applicationId: String? = nil, applicationSubmissionDate: Date? = nil, applicationIdExpiryDate: Date? = nil) {
        self.areaName = areaName
        self.networkingClient = networkingClient
        self.referralTrackingIdentifier = referralTrackingIdentifier
        self.nonce = nonce
        self.applicationId = applicationId
        self.applicationSubmissionDate = applicationSubmissionDate
        self.applicationIdExpiryDate = applicationIdExpiryDate
    }
    
}



extension FPOnboardingService {
    
    
    /// - Throws:
    ///   - `UNLOADED_ENTRY` on missing attributes
    ///   - `UNREACHABLE` on failure to connect with area
    ///   - `BAD_REQUEST` on missing params
    ///   - `AREA_CLOSED` when area isn't accepting any new members
    ///   - `UNEXPECTED_RESPONSE` for each unagreed-upon response
    static func makeFirstContactWithArea(areaJoinCode: AreaJoinCode) async -> Result<(onboardingService: FPOnboardingServicing, fields: [String]), FPError> {
        
        // Step 1 -- Make a rudimentary networking client with an empty middleware. 
        //           We have no need for credentials in this stage.
        let networkingClient = FPNetworkingClient(endpoint: areaJoinCode.endpoint, middlewares: [])
        
        
        do {
            
            // Step 2 -- Attempt a network request to the Area.
            let response = try await networkingClient.gateway.getEntryFormFields(.init(
                query: .init(ref: areaJoinCode.referralTrackingIdentifier),
                headers: .init(accept: [.init(contentType: .json)])
            ))
            
            
            // Step 3 -- Parse the response.
            switch response {
            case .ok(let rawResponse): switch rawResponse.body { case .json(let jsonBody):
                
                
                // Step 4 -- Guard the response to meet the expected format.
                guard
                    let areaName = jsonBody.data?.area_name,
                    let fields = jsonBody.data?.form_fields?.compactMap(\.field_label),
                    let nonce = jsonBody.data?.nonce
                else {
                    return .failure(.UNEXPECTED_RESPONSE)
                }
                
                return .success((
                    FPOnboardingService(areaName: areaName, 
                                        networkingClient: networkingClient, 
                                        referralTrackingIdentifier: areaJoinCode.referralTrackingIdentifier, 
                                        nonce: nonce),
                    fields
                ))
            }
            
            case .badRequest:
                VULogger.log(tag: .network, "Missing or invalid referral tracking identifier.")
                return .failure(.BAD_REQUEST)
            
            case .forbidden:
                VULogger.log(tag: .network, "Area isn't accepting any new members.")
                return .failure(.AREA_CLOSED)
                
            case .undocumented(statusCode: let code, let payload):
                VULogger.log(tag: .network, "\(code) - \(payload)")
                return .failure(.UNEXPECTED_RESPONSE)
            
            }
            
        } catch {
            VULogger.log(tag: .network, error)
            return .failure(.UNREACHABLE)
            
        }
    }
    
    
    /// - Throws:
    ///   - `UNLOADED_ENTRY` on missing attributes
    ///   - `UNREACHABLE` on failure to connect with area
    ///   - `BAD_REQUEST` on missing params
    ///   - `EMPTY_ARGUMENT` when area did an oopsie and didn't provide the expected `application_id` argument
    ///   - `UNEXPECTED_RESPONSE` on unagreed-upon response
    func submitApplicationForm(with fields: [String: String]) async -> Result<(applicationId: String, applicationExpiryDate: Date), FPError> {
        guard
            let networkingClient,
            let nonce
        else {
            return .failure(.UNLOADED_ENTRY)
        }
        
        let oneTimePrivateKey = P256.KeyAgreement.PrivateKey()
        do {
            let response = try await networkingClient.gateway.submitEntryForm(.init(
                query: .init(nonce: nonce),
                headers: .init(accept: [.init(contentType: .json)]),
                body: .init(.json(.init(
                    data: fields.map { label, answer in
                        .init(field_label: label, field_value: answer)
                    },
                    encryption_key: oneTimePrivateKey.publicKey.pemRepresentation
                )))
            ))
            
            switch response {
            case .ok(let output):
                switch output.body {
                case .json(let jsonBody):
                    guard 
                        let applicationId = jsonBody.data?.application_id,
                        let applicationExpiryDate = jsonBody.data?.application_expiry_date
                    else { 
                        return .failure(.EMPTY_ARGUMENT)
                    }
                    
                    return .success((
                        applicationId: applicationId,
                        applicationExpiryDate: applicationExpiryDate
                    ))
                }
                
            case .badRequest:
                VULogger.log(tag: .network, "Did not submit all the required fields and/or missing a valid nonce.")
                return .failure(.BAD_REQUEST)
                
            case .undocumented(statusCode: let code, let payload):
                VULogger.log(tag: .network, "\(code) - \(payload)")
                return .failure(.UNEXPECTED_RESPONSE)
            }
            
        } catch {
            VULogger.log(tag: .network, error)
            return .failure(.UNREACHABLE)
            
        }
    }
    
    
    /// - Throws:
    ///   - `UNLOADED_ENTRY` on missing attributes
    ///   - `UNREACHABLE` on failure to connect with area
    ///   - `BAD_REQUEST` on missing params
    ///   - `UNDECIDED_APPLICATION` when area havent rejected nor approved the application made by self
    ///   - `REJECTED_APPLICATION` when area rejects application made by self
    ///   - `UNEXPECTED_RESPONSE` on unagreed-upon response
    func checkApplicationStatus() async -> Result<String, FPError> {
        guard 
            let applicationId, 
            let networkingClient
        else {
            return .failure(.UNLOADED_ENTRY)
        }
        
        do {
            let response =  try await networkingClient.gateway.checkForEntryVerdict(.init(
                headers: .init(accept: [.init(contentType: .json)]),
                body: .json(.init(
                    application_id: applicationId
                ))
            ))
            
            switch response {
            case .ok(let output): switch output.body { case .json(let jsonBody):
                guard let authenticationCode = jsonBody.data?.authentication_code else {
                    return .failure(.UNDECIDED_APPLICATION)
                }
                    
                return .success(authenticationCode)
            }
                
            case .noContent:
                VULogger.log(tag: .network, "No approval yet.")
                return .failure(.UNDECIDED_APPLICATION)
                
            case .badRequest:
                VULogger.log(tag: .network, "Missing `application_id`.")
                return .failure(.BAD_REQUEST)
                
            case .forbidden: 
                VULogger.log(tag: .network, "Rejected application.")
                return .failure(.REJECTED_APPLICATION)
                
            case .undocumented(statusCode: let code, let payload):
                VULogger.log(tag: .network, "Unexpected response \(code) \(payload)")
                return .failure(.UNEXPECTED_RESPONSE)
            }
            
        } catch {
            VULogger.log(tag: .network, error)
            return .failure(.UNREACHABLE)
            
        }
    }
    
    
    /// 
    func cancelApplication() -> Result<Void, FPError> {
        return .success(())
    }
    
}



extension FPOnboardingService: VUMementoPerfectSnapshotable {
    
    
    /// Constructs a ``VUMementoSnapshot`` object, capturing the current state of the object.
    /// The attribute of ``networkingClient`` is omitted from snapshots.
    /// 
    /// - Returns: The snapshot of the object.
    /// - Throws: 
    ///   - `UNLOADED_ENTRY` when some of the attributes-to-be-snapped are not present.
    func captureSnapshot() -> Result<FPOnboardingServiceSnapshot, VUError> {
        guard
            let applicationId,
            let applicationSubmissionDate,
            let applicationIdExpiryDate
        else {
            return .failure(.UNLOADED_ENTRY)
        }
        
        let selfSnapshot = FPOnboardingServiceSnapshot(areaName: areaName,
                                                       applicationId: applicationId, 
                                                       applicationSubmissionDate: applicationSubmissionDate, 
                                                       applicationIdExpiryDate: applicationIdExpiryDate)
        return .success(selfSnapshot)
    }
    
    
    /// Restores the state according to the given snapshot.
    /// The attribute of ``networkingClient`` is omitted from snapshots.
    ///
    /// - Parameter snapshot: The snapshot to restore from.
    /// - Throws:
    ///   - `TYPE_MISMATCH` when the given ``VUMementoSnapshot`` object cannot be casted into ``FPOnboardingServiceSnapshot``.
    func restore(toSnapshot snp: FPOnboardingServiceSnapshot) -> Result<Void, Never> {
        self.areaName = snp.areaName
        self.applicationId = snp.applicationId
        self.applicationSubmissionDate = snp.applicationSubmissionDate
        self.applicationIdExpiryDate = snp.applicationIdExpiryDate
        
        return .success(())
    }
    
    
    
    /// Instantiates ``FPOnboardingService`` from its snapshot.
    static func boot(fromSnapshot snapshot: FPOnboardingServiceSnapshot) -> Result<FPOnboardingService, Never> {
        .success(
            FPOnboardingService(areaName: snapshot.areaName, 
                                networkingClient: nil, 
                                referralTrackingIdentifier: nil, 
                                nonce: nil, 
                                applicationId: snapshot.applicationId, 
                                applicationSubmissionDate: snapshot.applicationSubmissionDate, 
                                applicationIdExpiryDate: snapshot.applicationIdExpiryDate)
        )
    }
    
}
