import SwiftUI



/// The SwiftUI View that is bound to be presented in ``InboxViewController``.
struct InboxSwiftUIView: View {
    
    
    /// Two-ways communicator between ``InboxInteractor`` and self.
    @Bindable var viewModel: InboxSwiftUIViewModel
    
    
    var body: some View {
        List {
            if viewModel.notifications.count > 0 {
                let grouped = timeLoggedSection(fromNotifications: viewModel.notifications)
                ForEach(FPTimeLoggedSection.allCases, id: \.self) { section in 
                    if let sectionNotifs = grouped[section], !sectionNotifs.isEmpty {
                        Section(header: Text(section.rawValue)) {
                            ForEach(sectionNotifs) { notification in 
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
                        }
                    }
                }
                
            } else {
                ContentUnavailableView("Inbox is Empty", 
                                       systemImage: "envelope.open", 
                                       description: Text(
                                        """
                                        You haven't received any message just yet.
                                        
                                        When an important event occur, we'll notify you through notification, and you can access them here.
                                        """
                                       ))
            }
        }        
        .refreshable { 
            await viewModel.didIntendToRefreshMailbox?()
        }
    }
    
}



fileprivate func timeLoggedSection(fromNotifications notifications: [FPNotificationDigest]) -> [FPTimeLoggedSection: [FPNotificationDigest]] {
    Dictionary(grouping: notifications) { notification in
        if let submittedOnDate: Date = notification.sentOnDate {
            return FPTimeLoggedSection.category(for: submittedOnDate)
        } else {
            return FPTimeLoggedSection.category(for: .distantPast)
        }
    }
}



#Preview {
    @Previewable var viewModel = InboxSwiftUIViewModel()
    InboxSwiftUIView(viewModel: viewModel)
}
