import Foundation
import VinUtility



final class FPSessionIdentityUpkeeper: FPSessionIdentityUpkeeping {
    
    
    var storage: any FPSessionIdentityServicing
    
    
    var networkingClient: FPNetworkingClient
    
    
    init(storage: any FPSessionIdentityServicing, networkingClient: FPNetworkingClient) {
        self.storage = storage
        self.networkingClient = networkingClient
    }
    
    
    func renew() async throws {
        guard await storage.refreshTokenExpirationDate > .now else {
            throw FPError.INVALID_TOKEN
        }
        
        do {
            VULogger.log(tag: .network, "Renewing credentials.")
            
            switch try await networkingClient.gateway.refreshAccessTokenWithRefreshToken(.init(
                headers: .init(accept: [.init(contentType: .json)]),
                body: .json(.init(refresh_token: storage.refreshToken))
            )) {
                case .ok(let output): switch output.body { case .json(let jsonBody):
                    guard 
                        let accessToken = jsonBody.data?.access_token,
                        let accessTokenExpirationDate = jsonBody.data?.access_expiry_interval,
                        let roleString = jsonBody.data?.role_scope?.rawValue,
                        let role = FPTokenRole(rawValue: roleString)
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
                        return
                    }
                    
                    await storage.set(refreshToken: refreshToken)
                    await storage.set(refreshTokenExpirationDate: .now.addingTimeInterval(Double(refreshTokenExpirationDate)))
                    
                    VULogger.log(tag: .network, "Successful refresh with scope of \(role). New refresh token issued.")
                    return
                }
                    
                case .badRequest:
                    VULogger.log(tag: .network, "RefreshToken was not provided in the request.")
                    throw FPError.INCOMPLETE_ARGUMENT
                    
                case .unauthorized:
                    VULogger.log(tag: .network, "RefreshToken was invalid or has gone expired.")
                    throw FPError.INVALID_TOKEN
                
                case .forbidden:
                    VULogger.log(tag: .network, "No more refreshes allowed.")
                    throw FPError.FORBIDDEN
                    
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
