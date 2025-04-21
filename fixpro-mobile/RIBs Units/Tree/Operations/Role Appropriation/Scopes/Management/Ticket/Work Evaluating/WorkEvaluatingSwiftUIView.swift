import SwiftUI



/// The SwiftUI View that is bound to be presented in ``WorkEvaluatingViewController``.
struct WorkEvaluatingSwiftUIView: View {
    
    
    /// Two-ways communicator between ``WorkEvaluatingInteractor`` and self.
    @Bindable var viewModel: WorkEvaluatingSwiftUIViewModel
    
    
    var body: some View {
        Text("Hello from WorkEvaluatingSwiftUIView")
    }
    
}



#Preview {
    @Previewable var viewModel = WorkEvaluatingSwiftUIViewModel()
    WorkEvaluatingSwiftUIView(viewModel: viewModel)
}
