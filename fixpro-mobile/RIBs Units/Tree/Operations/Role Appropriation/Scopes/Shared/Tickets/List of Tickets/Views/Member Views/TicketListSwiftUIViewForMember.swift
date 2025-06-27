import SwiftUI
import VinUtility



fileprivate enum TicketListTab: String, CaseIterable, Hashable, Identifiable {
    case active = "Active"
    case past = "Past"
    
    var id: Self { self }
}



struct TicketListSwiftUIViewForMember: View {
    
    
    var viewModel: TicketListsSwiftUIViewModel
    
    
    @State fileprivate var activeTab: TicketListTab = .active
    
    
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
            case .active:
                SectionActive()
            case .past:
                SectionPast()
        }
    }
    
}



extension TicketListSwiftUIViewForMember {
    
    
    @ViewBuilder func SectionActive() -> some View {
        if viewModel.activeTickets.count <= 0 {
            Section {
                HStack(alignment: .top) {
                    ContentUnavailableView("No Tickets", 
                                           systemImage: "ticket", 
                                           description: Text("There are currently no ticket of yours that are yet to be resolved.\n\nWhen you open one, it'll show up here."))
                }
                .frame(height: 350)
                .padding(.top, VUViewSize.xxxBig.val * 3)
                .listRowInsets(.init())
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(Color.clear)
            }
            
        } else {
            Section {
                ActiveTicketsView(viewModel.activeTickets)
            } header: {
                Text("Active tickets")
            } footer: {
                Text(LocalizedStringResource("Active Tickets represents the ongoing operational issues in Bali Beach Indah which you’ve reported. Learn more about tickets’ state label [here](https://google.com)."))
            }
        }
    }
    
    
    @ViewBuilder func SectionPast() -> some View {
        if viewModel.pastTickets.count <= 0 {
            Section {
                HStack(alignment: .top) {
                    ContentUnavailableView("No Tickets", 
                                           systemImage: "ticket", 
                                           description: Text("There are currently no ticket of yours that has been resolved."))
                }
                .frame(height: 350)
                .padding(.top, VUViewSize.xxxBig.val * 3)
                .listRowInsets(.init())
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(Color.clear)
            }
            
        } else {
            Section {
                PastTicketsView(viewModel.pastTickets)
            } header: {
                Text("Past Tickets")
            } footer: {
                Text(LocalizedStringResource("Tickets are automatically closed after 3 days of inactions."))
            }
        }
    }
    
}



extension TicketListSwiftUIViewForMember {
    
    
    @ViewBuilder func ActiveTicketsView(_ activeTickets: [FPLightweightIssueTicket]) -> some View {
        ForEach(activeTickets) { ticket in
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
                    
                    FPIssueTicketStatusLabel(status: ticket.status)
                }
                
            }
        }
    }
    
    
    @ViewBuilder func PastTicketsView(_ pastTickets: [FPLightweightIssueTicket]) -> some View {
        ForEach(pastTickets) { ticket in
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
                    
                    FPIssueTicketStatusLabel(status: ticket.status)
                }
                
            }
        }
    }
    
}
