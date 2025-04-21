import SwiftUI
import VinUtility



/// The SwiftUI View that is bound to be presented in ``NewTicketViewController``.
struct NewTicketSwiftUIView: View {
    
    
    /// Two-ways communicator between ``NewTicketInteractor`` and self.
    @Bindable var viewModel: NewTicketSwiftUIViewModel
    
    
    var body: some View {
        VUPullToDismissScrollView {
            Text("Hello from NewTicketSwiftUIView")
        }
    }
    
}



#Preview {
    @Previewable var viewModel = NewTicketSwiftUIViewModel()
    NewTicketSwiftUIView(viewModel: viewModel)
}
