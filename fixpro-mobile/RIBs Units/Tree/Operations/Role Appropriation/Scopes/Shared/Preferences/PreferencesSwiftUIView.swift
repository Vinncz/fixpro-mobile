import SwiftUI



/// The SwiftUI View that is bound to be presented in ``PreferencesViewController``.
struct PreferencesSwiftUIView: View {
    
    
    /// Two-ways communicator between ``PreferencesInteractor`` and self.
    @Bindable var viewModel: PreferencesSwiftUIViewModel
    
    
    var body: some View {
        Form {
            Section {
                Button("Leave Area", role: .destructive) {
                    viewModel.logOut?()
                }
            } header: {
                Text("Dangerous zone")
            }
        }
    }
    
}



#Preview {
    @Previewable var viewModel = PreferencesSwiftUIViewModel()
    PreferencesSwiftUIView(viewModel: viewModel)
}
