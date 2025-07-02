import Foundation



enum FPTicketLogType: String, CaseIterable, Codable, Hashable, Identifiable {
    
    
    case select = "Select--"
    
    
    case assessment = "Assessment"
    
    
    case invitation = "Invitation"
    
    
    case workProgress = "Work Progress"
    
    
    case activity = "Activity"
    
    
    case workEvaluationRequest = "Work Evaluation Request"
    
    
    case workEvaluation = "Work Evaluation"
    
    
    case timeExtension = "Time Extension"
    
    
    case ownerEvaluationRequest = "Owner Evaluation Request"
    
    
    case rejection = "Rejection"
    
    
    case approval = "Approval"
    
    
    case forceClosure = "Force Closure"
    
    
    var id: Self { self } 
    
    
    var shorthand: String {
        switch self {
            case .activity:               return "Activity"
            case .assessment:             return "Assessment"
            case .select:                 return "Select"
            case .timeExtension:          return "Time Exten."
            case .workEvaluation:         return "Work Eval."
            case .workEvaluationRequest:  return "Work Eval. Req."
            case .workProgress:           return "Work Progress"
            case .invitation:             return "Invitation"
            case .ownerEvaluationRequest: return "Owner Evaluation Request"
            case .rejection:              return "Rejection"
            case .forceClosure:           return "Force Closure"
            case .approval:               return "Approval"
        }
    }
    
}
