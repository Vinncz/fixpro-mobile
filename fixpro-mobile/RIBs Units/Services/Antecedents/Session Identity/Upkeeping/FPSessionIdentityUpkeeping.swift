import Foundation
import VinUtility



/// 
protocol FPSessionIdentityUpkeeping: VUStatelessServicing {
    
    
    var storage: FPSessionIdentityServicing { get set }
    
    
    var networkingClient: FPNetworkingClient { get }
    
    
    func renew() async throws
    
}
