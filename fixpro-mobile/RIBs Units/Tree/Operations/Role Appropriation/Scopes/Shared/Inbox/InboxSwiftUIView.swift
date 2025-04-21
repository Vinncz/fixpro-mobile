import SwiftUI



/// The SwiftUI View that is bound to be presented in ``InboxViewController``.
struct InboxSwiftUIView: View {
    
    
    /// Two-ways communicator between ``InboxInteractor`` and self.
    @Bindable var viewModel: InboxSwiftUIViewModel
    
    
    var body: some View {
        Text("Hello from InboxSwiftUIView")
    }
    
}



#Preview {
    @Previewable var viewModel = InboxSwiftUIViewModel()
    InboxSwiftUIView(viewModel: viewModel)
}
