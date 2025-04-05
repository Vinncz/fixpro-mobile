import CryptoKit
import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

class FPPairingService: FPPairingServicing {
    
    var nextService: FPIdentitySessionService?
    
    var endpoint: String?
    var referralTrackingIdentifier: String? 
    var nonce: String?
    var applicationId: String?
    
    var storage: any FPTextStorageServicing
    
    init(storage: any FPTextStorageServicing) {
        self.storage = storage
    }
    
}

extension FPPairingService {
    

    func persists(_ information: String, forKey key: String) -> Result<Void, FPError> {
        _ = storage.remove(for: key)
        switch storage.place(for: key, data: information) {
            case .failure(let error): return .failure(error)
            case .success: return .success(())
        }
    }
    
    
    func getFormFieldsAndNonce() async -> Result<(fields: [String], nonce: String), FPError> {
        guard 
            let endpoint,
            let serverURL = URL(string: endpoint),
            let referralTrackingIdentifier
        else { 
            return .failure(.UNLOADED_ENTRY) 
        }
        
        let networkingClient = FPNetworkingClient(serverURL: serverURL, transport: URLSessionTransport())
        do {
            let response = try await networkingClient.getEntryFormFields(.init(
                query: .init(ref: referralTrackingIdentifier),
                headers: .init(accept: [.init(contentType: .json)])
            ))
            switch response {
                case .ok(let output):
                    switch output.body {
                        case .json(let jsonBody):
                            return .success((
                                fields: jsonBody.data?.form_fields?.compactMap(\.field_label) ?? [],
                                nonce: jsonBody.data?.nonce ?? ""
                            ))
                    }
                case .forbidden:
                    return .failure(FPError.FORBIDDEN)
                case .undocumented(statusCode: let code, let payload):
                    FPLogger.log(tag: .network, "\(code) - \(payload)")
                    return .failure(FPError.UNEXPECTED_RESPONSE)
                    
            }
            
        } catch {
            FPLogger.log(tag: .error, error)
            return .failure(.UNREACHABLE)
        }
    }
    
    
    func getApplicationId(bySubmittingTheFormFillout formFillout: [String: String]) async -> Result<String, FPError> {
        guard
            let endpoint,
            let serverURL = URL(string: endpoint),
            let nonce
        else {
            return .failure(.UNLOADED_ENTRY)
        }
        
        let networkingClient = FPNetworkingClient(serverURL: serverURL, transport: URLSessionTransport())
        let oneTimePrivateKey = P256.KeyAgreement.PrivateKey()
        do {
            let response = try await networkingClient.submitEntryForm(.init(
                query: .init(
                    nonce: nonce
                ),
                headers: .init(
                    accept: [.init(contentType: .json)]
                ),
                body: .init(.json(.init(
                    data: formFillout.map { label, answer in
                        .init(field_label: label, field_value: answer)
                    },
                    encryption_key: oneTimePrivateKey.publicKey.pemRepresentation
                )))
            ))
            switch response {
                case .ok(let output):
                    switch output.body {
                        case .json(let jsonBody):
                            guard let applicationId = jsonBody.data?.application_id else { 
                                return .failure(.EMPTY_ARGUMENT)
                            }
                            return .success(applicationId)
                    }
                case .badRequest:
                    return .failure(.BAD_REQUEST)
                case .forbidden:
                    return .failure(.FORBIDDEN)
                case .undocumented(statusCode: let code, let payload):
                    FPLogger.log(tag: .error, "\(code) - \(payload)")
                    return .failure(.UNEXPECTED_RESPONSE)
            }
            
        } catch {
            FPLogger.log(tag: .error, error)
            return .failure(.UNREACHABLE)
        }
    }
    
    
    func checkForApproval() async -> Result<String, FPError> {
        switch storage.retrieve(for: "applicationId", limit: 1) {
            case .success(let applicationId):
                
                switch storage.retrieve(for: "endpoint", limit: 1) {
                    case .success(let endpoint):
                        guard let serverURL = URL(string: endpoint) else {
                            FPLogger.log(tag: .error, "The saved endpoint cannot be reconstructed back into a URL.")
                            return .failure(.TYPE_MISMATCH)
                        }
                        
                        let networkingClient = FPNetworkingClient(serverURL: serverURL, transport: URLSessionTransport())
                        do {
                            let response = try await networkingClient.checkForEntryVerdict(.init(
                                query: .init(application_id: applicationId),
                                headers: .init(accept: [.init(contentType: .json)])
                            ))
                            switch response {
                                case .ok(let output):
                                    switch output.body {
                                        case .json(let jsonBody):
                                            guard let authenticationCode = jsonBody.data?.authentication_code else {
                                                return .failure(.FORBIDDEN)
                                            }
                                            return .success(authenticationCode)
                                    }
                                case .forbidden:
                                    return .failure(.FORBIDDEN)
                                case .undocumented(statusCode: let code, let payload):
                                    FPLogger.log(tag: .error, "\(code) - \(payload)")
                                    return .failure(.UNEXPECTED_RESPONSE)
                            }
                            
                        } catch {
                            return .failure(.UNREACHABLE)
                        }
                        
                    case .failure(let error):
                        FPLogger.log(tag: .error, "Endpoint isn't persisted where it should have been.")
                        return .failure(error)
                }
                
            case .failure(let error):
                FPLogger.log(tag: .error, "ApplicationId isn't persisted where it should have been.")
                return .failure(error)
        }
    }
    
}


extension FPPairingService {
    
    
    /// Initiates the transition to the next service.
    func transitionToNextService() {
        
    }
    
    
    /// Handles any cleanup or finalization before transitioning.
    func finalizeTransition() {
        // Implement the finalization logic here
    }
    
}
