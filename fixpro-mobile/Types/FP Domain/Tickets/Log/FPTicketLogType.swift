import Foundation



enum FPTicketLogType: String, CaseIterable, Codable, Hashable, Identifiable {
    
    
    case select = "Select--"
    
    
    case assessment = "Assessment"
    
    
    case workProgress = "Work Progress"
    
    
    case workEvaluationRequest = "Work Evaluation Request"
    
    
    case workEvaluation = "Work Evaluation"
    
    
    case activity = "Activity"
    
    
    case timeExtension = "Time Extension"
    
    
    var id: Self { self } 
    
    
    var shorthand: String {
        switch self {
            case .activity:              return "Activity"
            case .assessment:            return "Assessment"
            case .select:                return "Select"
            case .timeExtension:         return "Time Exten."
            case .workEvaluation:        return "Work Eval."
            case .workEvaluationRequest: return "Work Eval. Req."
            case .workProgress:          return "Work Progress"
        }
    }
    
}
