import SwiftUI



/// The SwiftUI View that is bound to be presented in ``SupportiveDocumentListViewController``.
struct SupportiveDocumentListSwiftUIView: View {
    
    
    /// Two-ways communicator between ``SupportiveDocumentListInteractor`` and self.
    @Bindable var viewModel: SupportiveDocumentListSwiftUIViewModel
    
    
    var body: some View {
        Text("Hello from SupportiveDocumentListSwiftUIView")
    }
    
}



#Preview {
    @Previewable var viewModel = SupportiveDocumentListSwiftUIViewModel()
    SupportiveDocumentListSwiftUIView(viewModel: viewModel)
}
