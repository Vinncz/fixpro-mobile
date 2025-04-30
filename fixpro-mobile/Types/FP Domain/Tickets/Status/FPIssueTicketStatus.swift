import SwiftUI



enum FPIssueTicketStatus: String, CaseIterable, Codable, Hashable, Identifiable {
    
    
    case open = "Open"
    
    
    case inAssessment = "In Assessment"
    
    
    case onProgress = "On Progress"
    
    
    case workEvaluation = "Work Evaluation"
    
    
    case closed = "Closed"
    
    
    case cancelled = "Cancelled"
    
    
    case rejected = "Rejected"
    
    
    var id: Self { self }
    
    
    var color: Color {
        switch self {
            case .open:
                return .blue
            case .inAssessment:
                return .orange
            case .onProgress:
                return .orange.opacity(0.8)
            case .workEvaluation:
                return .indigo
            case .closed:
                return .green
            case .cancelled:
                return .pink.opacity(0.8)
            case .rejected:
                return .red.opacity(0.8)
        }
    }
    
    
    var shorthandRepresentation: String {
        switch self {
            case .open:
                return "Open"
            case .inAssessment:
                return "In Asmt"
            case .onProgress:
                return "On Prog"
            case .workEvaluation:
                return "Work Eval"
            case .closed:
                return "Closed"
            case .cancelled:
                return "Canceled"
            case .rejected:
                return "Rejected"
        }
    }
    
}
