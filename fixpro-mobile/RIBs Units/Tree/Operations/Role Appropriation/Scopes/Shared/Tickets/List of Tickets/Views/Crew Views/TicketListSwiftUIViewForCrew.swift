import SwiftUI



struct TicketListSwiftUIViewForCrew: View {
    
    
    var viewModel: TicketListsSwiftUIViewModel
    
    
    var body: some View {
        Section {
            if viewModel.assignedTickets.count <= 0 {
                FPEmptyTicketRowView(systemImage: "checkmark", 
                                     message: "You are not assigned to any tickets.")
            } else {
                AssignedTicketsView(viewModel.assignedTickets)
            }
            
        } header: {
            Text("Tickets assigned to you")
            
        } footer: {
            Text("Tickets, depending on their response level, may require your attention. Plan your day accordingly. This is reflected in your calendar.")
            
        }
        
        Section {
            if viewModel.pastContributedTickets.count <= 0 {
                FPEmptyTicketRowView(systemImage: "checkmark.arrow.trianglehead.counterclockwise", 
                                     message: "You are not associated with any tickets just yet.")
            } else {
                CompletedContributedToTicketView(viewModel.pastContributedTickets)
            }
            
        } header: {
            Text("Past tickets")
            
        } footer: {
            Text(LocalizedStringResource("These are Tickets which you’ve contributed to, and are now addressed."))
            
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
