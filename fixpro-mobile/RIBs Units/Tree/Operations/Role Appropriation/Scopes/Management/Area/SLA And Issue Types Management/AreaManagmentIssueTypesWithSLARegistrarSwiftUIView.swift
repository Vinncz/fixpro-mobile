import SwiftUI



/// The SwiftUI View that is bound to be presented in ``AreaManagmentIssueTypesWithSLARegistrarViewController``.
struct AreaManagmentIssueTypesWithSLARegistrarSwiftUIView: View {
    
    
    /// Two-ways communicator between ``AreaManagmentIssueTypesWithSLARegistrarInteractor`` and self.
    @Bindable var viewModel: AreaManagmentIssueTypesWithSLARegistrarSwiftUIViewModel
    
    
    var body: some View {
        Text("Hello from AreaManagmentIssueTypesWithSLARegistrarSwiftUIView")
    }
    
}



#Preview {
    @Previewable var viewModel = AreaManagmentIssueTypesWithSLARegistrarSwiftUIViewModel()
    AreaManagmentIssueTypesWithSLARegistrarSwiftUIView(viewModel: viewModel)
}
