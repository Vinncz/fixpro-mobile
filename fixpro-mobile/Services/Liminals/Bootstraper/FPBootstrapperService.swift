import CryptoKit
import Foundation
import VinUtility



/// 
class FPBootstrapperService: FPBootstrapperServicing {
    
    
    // MARK: -- Discovery and first contact
    
    /// The name of the area issuing the `Area Join Code`.
    var areaName: String?
    
    
    /// The API address of the Area's FixPro Backend.
    var endpoint: String?
    lazy var endpointURL: URL? = {
        guard let endpoint else { return nil }
        return URL(string: endpoint)
    }()
    
    
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
    
}



extension FPBootstrapperService {
    
    
    /// - Throws:
    ///   - `UNLOADED_ENTRY` on missing attributes
    ///   - `UNREACHABLE` on failure to connect with area
    ///   - `BAD_REQUEST` on missing params
    ///   - `AREA_CLOSED` when area isn't accepting any new members
    ///   - `UNEXPECTED_RESPONSE` for each unagreed-upon response
    func makeFirstContactWithArea() async -> Result<(areaName: String, fields: [String], nonce: String), FPError> {
        guard 
            let endpoint,
            let endpointURL = URL(string: endpoint),
            let referralTrackingIdentifier
        else { 
            return .failure(.UNLOADED_ENTRY) 
        }
        
        let networkingClient = FPNetworkingClient(endpoint: endpointURL)
        do {
            let response = try await networkingClient.gateway.getEntryFormFields(.init(
                query: .init(ref: referralTrackingIdentifier),
                headers: .init(accept: [.init(contentType: .json)])
            ))
            switch response {
                case .ok(let output):
                    switch output.body {
                        case .json(let jsonBody):
                            return .success((
                                areaName: jsonBody.data?.area_name ?? "UNNAMED AREA",
                                fields: jsonBody.data?.form_fields?.compactMap(\.field_label) ?? [],
                                nonce: jsonBody.data?.nonce ?? ""
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
            let endpoint,
            let endpointURL = URL(string: endpoint),
            let nonce
        else {
            return .failure(.UNLOADED_ENTRY)
        }
        
        let networkingClient = FPNetworkingClient(endpoint: endpointURL)
        let oneTimePrivateKey = P256.KeyAgreement.PrivateKey()
        do {
            let response = try await networkingClient.gateway.submitEntryForm(.init(
                query: .init(
                    nonce: nonce
                ),
                headers: .init(
                    accept: [.init(contentType: .json)]
                ),
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
            let endpoint, 
            let endpointURL = URL(string: endpoint) 
        else {
            return .failure(.UNLOADED_ENTRY)
        }
        
        let networkingClient = FPNetworkingClient(endpoint: endpointURL)
        do {
            switch try await networkingClient.gateway.checkForEntryVerdict(.init(
                headers: .init(accept: [.init(contentType: .json)]),
                body: .json(.init(
                    application_id: applicationId
                ))
            )) {
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



extension FPBootstrapperService: VUMementoSnapshotable {
    
    
    /// Constructs a ``VUMementoSnapshot`` object, capturing the current state of the object.
    /// 
    /// - Returns: The snapshot of the object.
    /// - Throws: 
    ///   - `UNLOADED_ENTRY` when some of the attributes-to-be-snapped are not present.
    func captureSnapshot() -> Result<any VUMementoSnapshot, VUError> {
        guard
            let areaName,
            let applicationId,
            let applicationSubmissionDate,
            let applicationIdExpiryDate,
            let endpoint
        else {
            return .failure(.UNLOADED_ENTRY)
        }
        
        let selfSnapshot = FPBootstrapperServiceSnapshot(areaName: areaName,
                                                         applicationId: applicationId, 
                                                         applicationSubmissionDate: applicationSubmissionDate, 
                                                         applicationIdExpiryDate: applicationIdExpiryDate, 
                                                         endpoint: endpoint)
        return .success(selfSnapshot)
    }
    
    
    /// Restores the state according to the given snapshot.
    ///
    /// - Parameter snapshot: The snapshot to restore from.
    /// - Throws:
    ///   - `TYPE_MISMATCH` when the given ``VUMementoSnapshot`` object cannot be casted into ``FPBootstrapperServiceSnapshot``.
    func restore(from snapshot: any VUMementoSnapshot) -> Result<Void, VUError> {
        guard let snp = snapshot as? FPBootstrapperServiceSnapshot else {
            return .failure(.TYPE_MISMATCH)
        }
        
        self.areaName = snp.areaName
        self.applicationId = snp.applicationId
        self.applicationSubmissionDate = snp.applicationSubmissionDate
        self.applicationIdExpiryDate = snp.applicationIdExpiryDate
        self.endpoint = snp.endpoint
        
        return .success(())
    }
    
}
