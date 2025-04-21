import SwiftUI



/// The SwiftUI View that is bound to be presented in ``TicketListsViewController``.
struct TicketListsSwiftUIView: View {
    
    
    /// Two-ways communicator between ``TicketListsInteractor`` and self.
    @Bindable var viewModel: TicketListsSwiftUIViewModel
    
    
    var body: some View {
        Text("Hello from TicketListsSwiftUIView")
    }
    
}



#Preview {
    @Previewable var viewModel = TicketListsSwiftUIViewModel()
    TicketListsSwiftUIView(viewModel: viewModel)
}
