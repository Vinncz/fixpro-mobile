import Foundation
import VinUtility



func inferFileSize(from url: URL) -> Int64? {
    let fileManager = FileManager.default
    
    _ = url.startAccessingSecurityScopedResource()
    defer { url.stopAccessingSecurityScopedResource() }
    
    do {
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        if let fileSize = attributes[.size] as? Int64 {
            return fileSize
        }
        
    } catch {
        VULogger.log(tag: .error, "Error getting file attributes: \(error)")
    }
    
    return nil
}
