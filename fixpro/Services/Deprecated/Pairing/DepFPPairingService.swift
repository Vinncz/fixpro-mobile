import CryptoKit
import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

class DepFPPairingService: DepFPPairingServicing {
    
    private(set) var endpoint: String?
    private(set) var applicationId: String?
    private(set) var nonce: String?
    private(set) var referralTrackingIdentifier: String?
    
    private let storage: DepFPPairingServiceStorage
    private let sessionManager: DepFPSessionCredentialsManaging
    private let sessionStorage: DepFPSessionCredentialsStoring
    
    init(storage: DepFPPairingServiceStorage, sessionManager: DepFPSessionCredentialsManaging, sessionStorage: DepFPSessionCredentialsStoring) {
        self.storage = storage
        self.sessionManager = sessionManager
        self.sessionStorage = sessionStorage
    }
    
    enum Subject: String, CaseIterable {
        case applicationId
        case nonce
        case referralTrackingIdentifier
        case endpoint
    }
    
}


extension DepFPPairingService {
    
    func deloadEndpoint() {
        self.endpoint = ""
    }
    
    func load(endpoint: String) {
        self.endpoint = endpoint
    }
    
    func save(endpoint: String) {
        try self.storage
    }
    
}


extension DepFPPairingService {
    
    func load(nonce: String) {
        self.nonce = nonce
    }
    
    func deloadNonce() {
        self.nonce = nil
    }
    
}


extension DepFPPairingService {
    
    func load(referralTrackingIdentifier identifier: String) {
        self.referralTrackingIdentifier = identifier
    }
    
    func deloadReferralTrackingIdentifier() {
        self.referralTrackingIdentifier = nil
    }
    
}


extension DepFPPairingService {
    
    func populateApplicationId() throws {
        applicationId = try storage.retrieve(pairingServiceInformationForKey: Subject.applicationId.rawValue)
    }
    
    func removeApplicationId() throws {
        try storage.remove(pairingServiceInformationForKey: Subject.applicationId.rawValue)
        applicationId = nil
    }
    
    func save(applicationId: String) throws {
        self.applicationId = applicationId
    }
    
}


extension DepFPPairingService {
    
    /// 
    /// @return fields of the form; all of which are required.
    func fetchFormFields() async throws -> [String] {
        guard 
            let endpoint,
            let serverEndpoint = URL(string: endpoint)
        else {
            throw FPError.INVALID_ADDRESS
        }
        
        let client = Client(serverURL: serverEndpoint, transport: URLSessionTransport())
        let response = try await client.getEntryFormFields(.init(
            query: .init(ref: self.referralTrackingIdentifier), 
            headers: .init(
                accept: [.init(contentType: .json)]
            ))
        )
        
        switch response {
            case .ok(let output):
                switch output.body {
                    case .json(let jsonBody):
                        guard let array = jsonBody.data?.form_fields else { 
                            throw FPError.DERIVATION_FAILURE 
                        }
                        self.nonce = jsonBody.data?.nonce
                        
                        let fields = array.map({ $0.field_label }).map({ "\($0 as Any)" })
                        return fields
                }
            case .forbidden:
                throw FPError.FORBIDDEN
            case .undocumented(statusCode: let code, let payload):
                FPLogger.log(tag: .network, "Unexpected HTTP status code: \(code), payload: \(payload)")
                throw FPError.UNEXPECTED_RESPONSE
        }
    }
    
    
    /// 
    /// @return `application_id`
    func submitForm(withAnswersOf answer: [String: String]) async throws -> String {
        guard 
            let endpoint,
            let serverEndpoint = URL(string: endpoint),
            let nonce
        else {
            throw FPError.INVALID_ADDRESS
        }
        
        let client = Client(serverURL: serverEndpoint, transport: URLSessionTransport())
        let oneTimePrivateKey = P256.KeyAgreement.PrivateKey()
        let response = try await client.submitEntryForm(.init(
            query: .init(nonce: nonce), 
            headers: .init(
                accept: [.init(contentType: .json)]
            ),
            body: .init(.json(.init(
                data: answer.map { label, answer in
                    .init(field_label: label, field_value: answer)
                },
                encryption_key: oneTimePrivateKey.publicKey.pemRepresentation
            )))
        ))
        
        switch response {
            case .ok(let output):
                switch output.body {
                    case .json(let jsonBody):
                        guard let appId = jsonBody.data?.application_id else {
                            throw FPError.UNEXPECTED_RESPONSE
                        }
                        return appId
                }
            case .badRequest:
                throw FPError.BAD_REQUEST
            case .forbidden:
                throw FPError.FORBIDDEN
            case .undocumented(statusCode: let code, let payload):
                FPLogger.log(tag: .network, "Unexpected HTTP status code: \(code), payload: \(payload)")
                throw FPError.UNEXPECTED_RESPONSE
        }
    }
    
}
