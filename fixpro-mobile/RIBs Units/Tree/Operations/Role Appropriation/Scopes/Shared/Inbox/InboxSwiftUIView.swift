import SwiftUI



/// The SwiftUI View that is bound to be presented in ``InboxViewController``.
struct InboxSwiftUIView: View {
    
    
    /// Two-ways communicator between ``InboxInteractor`` and self.
    @Bindable var viewModel: InboxSwiftUIViewModel
    
    
    var body: some View {
        List(viewModel.notifications) { notification in
            FPChevronRowView {
                viewModel.didTapNotification?(notification)
            } children: {
                VStack(alignment: .leading) {
                    Text(notification.title)
                    Text(notification.body)
                        .foregroundStyle(.secondary)
                        .font(.callout)
                }
                .lineLimit(1)
                .truncationMode(.tail)
            }
        }
        .refreshable { 
            await viewModel.didIntendToRefreshMailbox?()
        }
    }
    
}



#Preview {
    @Previewable var viewModel = InboxSwiftUIViewModel()
    InboxSwiftUIView(viewModel: viewModel)
}
