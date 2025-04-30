import Foundation
import VinUtility



func fileToBase64(on url: URL) -> String? {
    do {
        let fileData = try Data(contentsOf: url)
        return fileData.base64EncodedString()
        
    } catch {
        VULogger.log(tag: .error, "Error reading file: \(error)")
        return nil
    }
    
}
