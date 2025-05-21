import SwiftUI



/// The SwiftUI View that is bound to be presented in ``AreaManagementStatisticsViewController``.
struct AreaManagementStatisticsSwiftUIView: View {
    
    
    /// Two-ways communicator between ``AreaManagementStatisticsInteractor`` and self.
    @Bindable var viewModel: AreaManagementStatisticsSwiftUIViewModel
    
    
    var body: some View {
        Text("Hello from AreaManagementStatisticsSwiftUIView")
    }
    
}



#Preview {
    @Previewable var viewModel = AreaManagementStatisticsSwiftUIViewModel()
    AreaManagementStatisticsSwiftUIView(viewModel: viewModel)
}
