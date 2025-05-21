import SwiftUI



/// The SwiftUI View that is bound to be presented in ``AreaManagementApplicationReviewAndManagementViewController``.
struct AreaManagementApplicationReviewAndManagementSwiftUIView: View {
    
    
    /// Two-ways communicator between ``AreaManagementApplicationReviewAndManagementInteractor`` and self.
    @Bindable var viewModel: AreaManagementApplicationReviewAndManagementSwiftUIViewModel
    
    
    var body: some View {
        Text("Hello from AreaManagementApplicationReviewAndManagementSwiftUIView")
    }
    
}



#Preview {
    @Previewable var viewModel = AreaManagementApplicationReviewAndManagementSwiftUIViewModel()
    AreaManagementApplicationReviewAndManagementSwiftUIView(viewModel: viewModel)
}
