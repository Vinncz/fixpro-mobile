import SwiftUI
import VinUtility



/// The SwiftUI View that is bound to be presented in ``TicketListsViewController``.
struct TicketListsSwiftUIView: View {
    
    
    /// Two-ways communicator between ``TicketListsInteractor`` and self.
    @Bindable var viewModel: TicketListsSwiftUIViewModel
    
    
    var body: some View {
        List {
            switch viewModel.roleContext.role {
            case .member:
                TicketListSwiftUIViewForMember(viewModel: viewModel)
            case .crew:
                TicketListSwiftUIViewForCrew(viewModel: viewModel)
            case .management:
                TicketListSwiftUIViewForManagement(viewModel: viewModel)
            }
        }
        .refreshable {
            await viewModel.didIntendToRefreshTicketList()
        }
        .navigationTitle("Home")
    }
    
}



#Preview {
    @Previewable var viewModel = TicketListsSwiftUIViewModel(roleContext: .init(role: .member), 
                                                             tickets: [], 
                                                             didIntendToRefreshTicketList: {}, 
                                                             didTapTicket: {_ in})
    TicketListsSwiftUIView(viewModel: viewModel)
}
