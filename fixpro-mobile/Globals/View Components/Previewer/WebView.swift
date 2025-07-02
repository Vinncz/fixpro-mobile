import Foundation
import VinUtility
import os
import SwiftUI
import WebKit



struct FPWebView : UIViewRepresentable {
    
    
    let contentAddressToPreview: URL
    
    
    @Binding var previewFault: String?
    
    
    var scrollEnabled: Bool
    
    
    class Coordinator: NSObject, WKNavigationDelegate {
        
        
        var parent: FPWebView
        
        
        init ( _ parent: FPWebView ) {
            self.parent = parent
        }
        
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            handle(error: error)
        }
        
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            handle(error: error)
        }
        
        
        private func handle(error: Error) {
            switch classifyWebKitError(error) {
                case .benign:
                    Logger().error("\(error.localizedDescription)")
                case .critical:
                    Task { @MainActor in
                        self.parent.previewFault = error.localizedDescription
                    }
            }
        }
        
    }
    
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = scrollEnabled
        webView.scrollView.bounces = scrollEnabled
        webView.navigationDelegate = context.coordinator
        
//        webView.loadFileURL(contentAddressToPreview, allowingReadAccessTo: contentAddressToPreview.deletingLastPathComponent())
        webView.load(URLRequest(url: contentAddressToPreview))
        return webView
    }
    
    
    func updateUIView ( _ webView: WKWebView, context: Context ) {}
    
    
    func makeCoordinator () -> Coordinator { Coordinator(self) }
    
}

enum WebViewErrorType {
    case benign
    case critical
}



func classifyWebKitError ( _ error: Error ) -> WebViewErrorType {
    let nsError = error as NSError

    switch (nsError.domain, nsError.code) {
    case (NSURLErrorDomain, NSURLErrorCancelled):
        return .benign // User navigated away before loading finished (common)
        
    case (NSURLErrorDomain, NSURLErrorNotConnectedToInternet):
        return .critical // No internet, user needs to know
        
    case (NSURLErrorDomain, NSURLErrorTimedOut):
        return .critical // Server too slow, show error

    case (NSURLErrorDomain, NSURLErrorUnsupportedURL):
        return .critical // Bad URL format
    
    case (WKError.errorDomain, 1):
        return .benign
    
    case (WKError.errorDomain, 102):
        return .benign // "Frame load interrupted" – harmless in most cases
            
    case (WKError.errorDomain, 204):
        return .benign

    default:
        return .benign // god please forgive me for I have no idea what escaped the filter above.
    }
}




struct FPWebViewWithURLRequest : UIViewRepresentable {
    
    
    let request: URLRequest
    
    
    @Binding var previewFault: String?
    
    
    var scrollEnabled: Bool
    
    
    class Coordinator: NSObject, WKNavigationDelegate {
        
        
        var parent: FPWebViewWithURLRequest
        
        
        init ( _ parent: FPWebViewWithURLRequest ) {
            self.parent = parent
        }
        
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            handle(error: error)
        }
        
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            handle(error: error)
        }
        
        
        private func handle(error: Error) {
            switch classifyWebKitError(error) {
                case .benign:
                    VULogger.log(tag: .error, "\(error.localizedDescription)")
                case .critical:
                    Task { @MainActor in
                        self.parent.previewFault = error.localizedDescription
                    }
            }
        }
        
    }
    
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = scrollEnabled
        webView.scrollView.bounces = scrollEnabled
        webView.navigationDelegate = context.coordinator
        
//        webView.loadFileURL(contentAddressToPreview, allowingReadAccessTo: contentAddressToPreview.deletingLastPathComponent())
        webView.load(request)
        print(urlRequest: request)
        return webView
    }
    
    
    func updateUIView ( _ webView: WKWebView, context: Context ) {}
    
    
    func makeCoordinator () -> Coordinator { Coordinator(self) }
    
}
