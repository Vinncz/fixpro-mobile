import SwiftUI
import QuickLook



struct QuickLookPreview: UIViewControllerRepresentable {
    
    
    let fileURL: URL
    
    
    func makeUIViewController(context: Context) -> UIViewController {
        let container = UIViewController()
        let previewController = QLPreviewController()
        previewController.dataSource = context.coordinator
        previewController.isModalInPresentation = true
        container.isModalInPresentation = true
        
        previewController.presentationController?.delegate = context.coordinator
        
        container.addChild(previewController)
        container.view.addSubview(previewController.view)
        previewController.view.frame = container.view.bounds
        previewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        previewController.didMove(toParent: container)
        
        return container
    }
    
    
    func updateUIViewController(_ controller: UIViewController, context: Context) {}
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(fileURL: fileURL)
    }
    
    
    class Coordinator: NSObject, QLPreviewControllerDataSource, UIAdaptivePresentationControllerDelegate {
        
        
        let fileURL: URL
        

        init(fileURL: URL) {
            self.fileURL = fileURL
        }
        

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return fileURL as QLPreviewItem
        }
        
        
        func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
            return false
        }
        
    }
}
