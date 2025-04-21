import SwiftUI



/// The SwiftUI View that is bound to be presented in ``CrewDelegatingViewController``.
struct CrewDelegatingSwiftUIView: View {
    
    
    /// Two-ways communicator between ``CrewDelegatingInteractor`` and self.
    @Bindable var viewModel: CrewDelegatingSwiftUIViewModel
    
    
    var body: some View {
        Text("Hello from CrewDelegatingSwiftUIView")
    }
    
}



#Preview {
    @Previewable var viewModel = CrewDelegatingSwiftUIViewModel()
    CrewDelegatingSwiftUIView(viewModel: viewModel)
}
