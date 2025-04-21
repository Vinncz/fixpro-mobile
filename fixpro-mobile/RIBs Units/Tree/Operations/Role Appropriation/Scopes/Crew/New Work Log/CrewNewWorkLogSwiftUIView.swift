import SwiftUI



/// The SwiftUI View that is bound to be presented in ``CrewNewWorkLogViewController``.
struct CrewNewWorkLogSwiftUIView: View {
    
    
    /// Two-ways communicator between ``CrewNewWorkLogInteractor`` and self.
    @Bindable var viewModel: CrewNewWorkLogSwiftUIViewModel
    
    
    var body: some View {
        Text("Hello from CrewNewWorkLogSwiftUIView")
    }
    
}



#Preview {
    @Previewable var viewModel = CrewNewWorkLogSwiftUIViewModel()
    CrewNewWorkLogSwiftUIView(viewModel: viewModel)
}
