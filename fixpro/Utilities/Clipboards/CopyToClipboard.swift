import UIKit

/// Copies the given text argument to the clipboard.
func copyToClipboard ( _ inputText: String ) {
    let pasteboard = UIPasteboard.general
    pasteboard.string = inputText
}
