import Foundation
import Observation



/// Bridges between ``StatisticsAndReportsSwiftUIView`` and the ``StatisticsAndReportsInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class StatisticsAndReportsSwiftUIViewModel {
    
    
    var bundles: [StatisticsAndReportsBundle] = []
    
    
    var didIntendToRefresh: (()async throws->Void)?
    
}



struct StatisticsAndReportsBundle: Identifiable {
    
    
    var id = UUID()
    
    
    var month: String
    
    
    var year: String
    
    
    var periodicReportLink: URL
    
    
    var ticketSummarizationLink: URL
    
}
