import SwiftUI



/// The SwiftUI View that is bound to be presented in ``TicketLogViewController``.
struct TicketLogSwiftUIView: View {
    
    
    /// Two-ways communicator between ``TicketLogInteractor`` and self.
    @Bindable var viewModel: TicketLogSwiftUIViewModel
    
    
    var body: some View {
        Text("Hello from TicketLogSwiftUIView")
    }
    
}



#Preview {
    @Previewable var viewModel = TicketLogSwiftUIViewModel()
    TicketLogSwiftUIView(viewModel: viewModel)
}
