import SwiftUI



/// The SwiftUI View that is bound to be presented in ``PreferencesViewController``.
struct PreferencesSwiftUIView: View {
    
    
    /// Two-ways communicator between ``PreferencesInteractor`` and self.
    @Bindable var viewModel: PreferencesSwiftUIViewModel
    
    
    var body: some View {
        Text("Hello from PreferencesSwiftUIView")
    }
    
}



#Preview {
    @Previewable var viewModel = PreferencesSwiftUIViewModel()
    PreferencesSwiftUIView(viewModel: viewModel)
}
