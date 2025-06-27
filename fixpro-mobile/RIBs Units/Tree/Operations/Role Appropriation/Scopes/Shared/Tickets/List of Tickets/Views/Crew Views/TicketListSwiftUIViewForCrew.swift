import SwiftUI
import VinUtility



fileprivate enum TicketListTab: String, CaseIterable, Hashable, Identifiable {
    case toDo = "To Do"
    case contributed = "Contributed"
    
    var id: Self { self }
}



struct TicketListSwiftUIViewForCrew: View {
    
    
    var viewModel: TicketListsSwiftUIViewModel
    
    
    @State fileprivate var activeTab: TicketListTab = .toDo
    
    
    var body: some View {
        Picker("Tabs", selection: $activeTab) {
            ForEach(TicketListTab.allCases) { tab in
                Text(tab.rawValue)
            }
        }
        .pickerStyle(.segmented)
        .listRowInsets(.init())
        .listRowSpacing(0)
        .listRowBackground(Color.clear)
        .listRowSeparatorTint(Color.clear)
        
        switch activeTab {
            case .toDo:
                SectionToDo()
            case .contributed:
                SectionContributed()
        }
    }
    
}



extension TicketListSwiftUIViewForCrew {
    
    
    @ViewBuilder func SectionToDo() -> some View {
        if viewModel.assignedTickets.count <= 0 {
            Section {
                HStack(alignment: .top) {
                    ContentUnavailableView("No Tickets", 
                                           systemImage: "tray", 
                                           description: Text("You have not been assigned to any tickets.\n\nWhen you are assigned to one,\nthey'll be shown here."))
                }
                .frame(height: 350)
                .padding(.top, VUViewSize.xxxBig.val * 3)
                .listRowInsets(.init())
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(Color.clear)
            }
        } else {
            Section {
                AssignedTicketsView(viewModel.assignedTickets)
            } header: {
                Text("Tickets assigned to you")
            } footer: {
                Text("Tickets, depending on their response level, may require your attention. Plan your day accordingly. This is reflected in your calendar.")
            }
        }
    }
    
    
    @ViewBuilder func SectionContributed() -> some View {
        if viewModel.pastContributedTickets.count <= 0 {
            Section {
                HStack(alignment: .top) {
                    ContentUnavailableView("No Tickets", 
                                           systemImage: "checkmark.arrow.trianglehead.counterclockwise", 
                                           description: Text("You have not contributed to any active ticket just yet.\n\nWhen you have, they'll be shown here."))
                }
                .frame(height: 350)
                .padding(.top, VUViewSize.xxxBig.val * 3)
                .listRowInsets(.init())
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(Color.clear)
            }
        } else {
            Section {
                CompletedContributedToTicketView(viewModel.pastContributedTickets)
            } header: {
                Text("Past tickets")
            } footer: {
                Text(LocalizedStringResource("These are Tickets which you’ve contributed to, and are now addressed."))
            }
        }
    }
    
}



extension TicketListSwiftUIViewForCrew {
    
    
    @ViewBuilder func AssignedTicketsView(_ assignedTickets: [FPLightweightIssueTicket]) -> some View {
        ForEach(assignedTickets) { ticket in
            FPChevronRowView { 
                viewModel.didTapTicket(ticket)
                
            } children: { 
                HStack {
                    VStack(alignment: .leading) {
                        Text(ticket.executiveSummary ?? ticket.id)
                            .lineLimit(1)
                        
                        Text(dateToString(date: (try? Date(ticket.raisedOn, strategy: .iso8601)) ?? .now))
                            .foregroundStyle(.secondary)
                            .font(.callout)
                    }
                    Spacer()
                    
                    FPIssueTicketResponseLevelLabel(responseLevel: ticket.responseLevel)
                }
                
            }
        }
    }
    
    
    @ViewBuilder func ActiveContributedToTicketView() -> some View {
        
    }
    
    
    @ViewBuilder func CompletedContributedToTicketView(_ pastContributedTickets: [FPLightweightIssueTicket]) -> some View {
        ForEach(pastContributedTickets) { ticket in
            FPChevronRowView { 
                viewModel.didTapTicket(ticket)
                
            } children: { 
                HStack {
                    VStack(alignment: .leading) {
                        Text(ticket.executiveSummary ?? ticket.id)
                            .lineLimit(1)
                        
                        Text(dateToString(date: (try? Date(ticket.closedOn ?? "", strategy: .iso8601)) ?? .now))
                            .foregroundStyle(.secondary)
                            .font(.callout)
                    }
                    Spacer()
                    
                    FPIssueTicketResponseLevelLabel(responseLevel: ticket.responseLevel)
                }
                
            }
        }
    }
    
}
