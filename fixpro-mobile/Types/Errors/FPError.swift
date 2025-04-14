import VinUtility

typealias FPError = VUError

extension FPError {
    
    static let AREA_CLOSED = FPError(
        name: "AREA_CLOSED", 
        code: 0b0000_0000, 
        domain: .Custom, 
        userInfo: [
            :
        ]
    )
    
    static let SUBMISSION_FAILURE = FPError(
        name: "SUBMISSION_FAILURE", 
        code: 0b0000_0001, 
        domain: .Custom, 
        userInfo: [
            :
        ]
    )
    
    static let REJECTED_APPLICATION = FPError(
        name: "REJECTED_APPLICATION", 
        code: 0b0000_0010, 
        domain: .Custom, 
        userInfo: [
            :
        ]
    )
    
    static let UNDECIDED_APPLICATION = FPError(
        name: "UNDECIDED_APPLICATION", 
        code: 0b0000_0011, 
        domain: .Custom, 
        userInfo: [
            :
        ]
    )
    
}
