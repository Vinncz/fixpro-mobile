import SwiftUI



/// The SwiftUI View that is bound to be presented in ``ContactInformationViewController``.
struct ContactInformationSwiftUIView: View {
    
    
    /// Two-ways communicator between ``ContactInformationInteractor`` and self.
    @Bindable var viewModel: ContactInformationSwiftUIViewModel
    
    
    var body: some View {
        Text("Hello from ContactInformationSwiftUIView")
    }
    
}



#Preview {
    @Previewable var viewModel = ContactInformationSwiftUIViewModel()
    ContactInformationSwiftUIView(viewModel: viewModel)
}
