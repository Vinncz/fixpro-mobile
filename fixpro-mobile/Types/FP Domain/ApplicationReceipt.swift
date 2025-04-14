import Foundation



struct ApplicationReceipt {
    
    var areaName: String
    
    var appliedOnDate: Date
    
    var offerExpiryDate: Date
    
    var isValid: Bool {
        offerExpiryDate > .now
    }
    
}
