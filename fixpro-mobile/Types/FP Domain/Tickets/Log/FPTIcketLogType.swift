import Foundation



enum FPTIcketLogType: String, CaseIterable, Codable, Hashable, Identifiable {
    
    
    case select = "Select--"
    
    
    case assessment = "Assessment"
    
    
    case workProgress = "Work Progress"
    
    
    case workEvaluationRequest = "Work Evaluation Request"
    
    
    case workEvaluation = "Work Evaluation"
    
    
    case activity = "Activity"
    
    
    case timeExtension = "Time Extension"
    
    
    var id: Self { self } 
    
}
