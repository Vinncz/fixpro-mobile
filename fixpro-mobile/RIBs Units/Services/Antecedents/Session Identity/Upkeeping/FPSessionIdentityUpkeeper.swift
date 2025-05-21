import Foundation
import VinUtility



final class FPSessionIdentityUpkeeper: FPSessionIdentityUpkeeping {
    
    
    var storage: any FPSessionIdentityServicing
    
    
    var networkingClient: FPNetworkingClient
    
    
    var mementoAgent: FPMementoAgent<FPSessionIdentityService, FPSessionIdentityServiceSnapshot>
    
    
    init(storage: any FPSessionIdentityServicing, networkingClient: FPNetworkingClient, mementoAgent: FPMementoAgent<FPSessionIdentityService, FPSessionIdentityServiceSnapshot>) {
        self.storage = storage
        self.networkingClient = networkingClient
        self.mementoAgent = mementoAgent
    }
    
    
    func renew() async throws {
        guard await storage.refreshTokenExpirationDate > .now else {
            throw FPError.EXPIRED_REFRESH_TOKEN
        }
        
        do {
            VULogger.log(tag: .network, "Renewing credentials.")
            
            switch try await networkingClient.gateway.oauthRefresh(.init(
                headers: .init(accept: [.init(contentType: .json)]),
                body: .json(.init(refresh_token: storage.refreshToken))
            )) {
                case .ok(let output): switch output.body { case .json(let jsonBody):
                    guard 
                        let accessToken = jsonBody.data?.access_token,
                        let accessTokenExpirationDate = jsonBody.data?.access_expiry_interval,
                        let role = FPTokenRole(rawValue: "\(jsonBody.data?.role_scope?.value ?? "")")
                    else {
                        throw FPError.DECODE_FAILURE
                    }
                    
                    
                    await storage.set(accessToken: accessToken)
                    await storage.set(accessTokenExpirationDate: .now.addingTimeInterval(Double(accessTokenExpirationDate)))
                        
                    await storage.set(role: role)
                    
                    
                    guard
                        let refreshToken = jsonBody.data?.refresh_token,
                        let refreshTokenExpirationDate = jsonBody.data?.refresh_expiry_interval
                    else {
                        VULogger.log(tag: .network, "Successful refresh with scope of \(role). No refresh token issued.")
                        await mementoAgent.snap()
                        return
                    }
                    
                    await storage.set(refreshToken: refreshToken)
                    await storage.set(refreshTokenExpirationDate: .now.addingTimeInterval(Double(refreshTokenExpirationDate)))
                    
                    VULogger.log(tag: .network, "Successful refresh with scope of \(role). New refresh token issued.")
                    await mementoAgent.snap()
                    return
                }
                    
                case .undocumented(statusCode: let code, let payload):
                    VULogger.log(tag: .network, "Area responded with an unexpected response. \(code) • \(payload)")
                    throw FPError.UNEXPECTED_RESPONSE
            }
            
        } catch {
            VULogger.log(tag: .network, "Unable to contact area. \(error)")
            throw FPError.UNREACHABLE
            
        }
    }
    
}
