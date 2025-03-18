import UIKit

/// Pastes the content of clipboard into the given address.
func pasteFromClipboard ( to address: inout String ) {
    let pasteboard = UIPasteboard.general
    
    guard pasteboard.hasStrings, pasteboard.string?.isEmpty == false, let str = pasteboard.string else {
        return
    }
    
    address = str
}
