import Foundation
import Observation



/// Bridges between ``StatisticsAndReportsSwiftUIView`` and the ``StatisticsAndReportsInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class StatisticsAndReportsSwiftUIViewModel {
    
    
    var component: StatisticsAndReportsComponent
    
    
    var bundles: [StatisticsAndReportsBundle]
    
    
    init(component: StatisticsAndReportsComponent, bundles: [StatisticsAndReportsBundle]) {
        self.component = component
        self.bundles = bundles
    }
    
    
    func urlRequest (from url: URL) async -> URLRequest {
        var req = URLRequest(url: url)
        await req.setValue("Bearer \(component.identityService.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        return req
    }
    
    
    var didIntendToRefresh: (()async throws->Void)?
    
}



struct StatisticsAndReportsBundle: Identifiable {
    
    
    var id = UUID()
    
    
    var month: String
    
    
    var year: String
    
    
    var periodicReportLink: URL
    
    
    var ticketSummarizationLink: URL
    
}
