import SwiftUI



struct TicketListSwiftUIViewForMember: View {
    
    
    var viewModel: TicketListsSwiftUIViewModel
    
    
    var body: some View {
        Section {
            if viewModel.activeTickets.count <= 0 {
                ContentUnavailableView("No active tickets", systemImage: "ticket")
                    .labelStyle(.titleOnly)
            } else {
                ActiveTicketsView(viewModel.activeTickets)
            }
            
        } header: {
            Text("Active tickets")
            
        } footer: {
            Text(LocalizedStringResource("Active Tickets represents the ongoing operational issues in Bali Beach Indah which you’ve reported. Learn more about tickets’ state label [here](https://google.com)."))
            
        }
        
        Section {
            if viewModel.pastTickets.count <= 0 {
                ContentUnavailableView("No past tickets", systemImage: "ticket")
                    .labelStyle(.titleOnly)
            } else {
                PastTicketsView(viewModel.pastTickets)
            }
            
        } header: {
            Text("Past Tickets")
            
        } footer: {
            Text(LocalizedStringResource("Tickets are automatically closed after 3 days of inactions."))
            
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
                        
                        Text(dateToString(date: ticket.raisedOn))
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
                        
                        Text(dateToString(date: ticket.closedOn ?? Date()))
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
