import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import VinUtility



class FPNetworkingClient {
    
    
    var gateway: Client
    
    
    var endpoint: URL
    
    
    var middlewares: [ClientMiddleware]
    
    
    init(endpoint: URL, middlewares: [ClientMiddleware]) {
        self.middlewares = middlewares
        self.gateway = Client(serverURL: endpoint, 
                              configuration: .init(
                                dateTranscoder: .iso8601,
                                jsonEncodingOptions: []
                              ),
                              transport: URLSessionTransport(), 
                              middlewares: middlewares)
        self.endpoint = endpoint
    }
    
    
    func deepCopy() -> FPNetworkingClient {
        FPNetworkingClient(endpoint: endpoint, middlewares: middlewares)
    }
    
}



extension FPNetworkingClient: VUMementoSnapshotable, VUMementoSnapshotBootable {
    
    
    func captureSnapshot() async -> Result<FPNetworkingClientSnapshot, Never> {
        .success(FPNetworkingClientSnapshot(endpoint: endpoint))
    }
    
    
    func restore(toSnapshot snapshot: FPNetworkingClientSnapshot) async -> Result<Void, Never> {
        self.gateway = Client(serverURL: snapshot.endpoint, transport: URLSessionTransport(), middlewares: [])
        self.endpoint = snapshot.endpoint
        
        return .success(())
    }
    
    
    static func boot(fromSnapshot snapshot: FPNetworkingClientSnapshot) -> Result<FPNetworkingClient, Never> {
        .success(FPNetworkingClient(endpoint: snapshot.endpoint, middlewares: []))
    }
    
}
