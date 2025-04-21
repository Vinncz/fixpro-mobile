import SwiftUI



/// The SwiftUI View that is bound to be presented in ``LocationDetailFromTicketDetailViewController``.
struct LocationDetailFromTicketDetailSwiftUIView: View {
    
    
    /// Two-ways communicator between ``LocationDetailFromTicketDetailInteractor`` and self.
    @Bindable var viewModel: LocationDetailFromTicketDetailSwiftUIViewModel
    
    
    var body: some View {
        Text("Hello from LocationDetailFromTicketDetailSwiftUIView")
    }
    
}



#Preview {
    @Previewable var viewModel = LocationDetailFromTicketDetailSwiftUIViewModel()
    LocationDetailFromTicketDetailSwiftUIView(viewModel: viewModel)
}
