import SwiftUI



/// The SwiftUI View that is bound to be presented in ``AreaManagementViewController``.
struct AreaManagementSwiftUIView: View {
    
    
    /// Two-ways communicator between ``AreaManagementInteractor`` and self.
    @Bindable var viewModel: AreaManagementSwiftUIViewModel
    
    
    var body: some View {
        Text("Hello from AreaManagementSwiftUIView")
    }
    
}



#Preview {
    @Previewable var viewModel = AreaManagementSwiftUIViewModel()
    AreaManagementSwiftUIView(viewModel: viewModel)
}
