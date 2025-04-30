import SwiftUI



struct TicketListSwiftUIViewForManagement: View {
    
    
    var viewModel: TicketListsSwiftUIViewModel
    
    
    var body: some View {
        Section {
            if viewModel.ticketsToAssess.count <= 0 {
                FPEmptyTicketRowView(systemImage: "checkmark", 
                                     message: "No new ticket to assess.")
            } else {
                TicketsToAssessView(viewModel.ticketsToAssess)
            }
        } header: {
            Text("Open tickets in need of attention")
        } footer: {
            Text(LocalizedStringResource("These Tickets represents ongoing operational problems in Area you manage. [Learn more](https://google.com)."))
        }
        
        Section {
            if viewModel.ticketsToEvaluate.count <= 0 {
                FPEmptyTicketRowView(systemImage: "checkmark.rectangle.stack", 
                                     message: "No ticket to evaluate.")
            } else {
                TicketsToEvaluateView(viewModel.ticketsToEvaluate)
            }
        } header: {
            Text("Tickets awaiting evaluation")
        } footer: {
            Text(LocalizedStringResource("These are Tickets which were reported as ‘solved’ by your maintenance crew colleague. For quality control, you may want to assess them. [Learn more](https://google.com)."))
        }
        
        Section {
            if viewModel.ticketsUnderProgress.count <= 0 {
                FPEmptyTicketRowView(systemImage: "checkmark.rectangle.stack", 
                                     message: "No open tickets are being worked on right now.")
            } else {
                TicketsUnderProgressView(viewModel.ticketsUnderProgress)
            }
        } header: {
            Text("Tickets under progress")
        } footer: {
            Text("These are Tickets that have been delegated to your crew colleagues. They aren't yet resolved, but when they are, your colleagues can request for your evaluation. [Learn more](https://google.com).")
        }
        
        Section {
            if viewModel.pastResolvedTickets.count <= 0 {
                FPEmptyTicketRowView(systemImage: "clock.badge.checkmark", 
                                     message: "No tickets have ever been raised. Good job!")
            } else {
                PastResolvedTicketsView(viewModel.pastResolvedTickets)
            }
            
        } header: {
            Text("Past resolved tickets")
        } footer: {
            Text("These are Tickets that you and your colleagues have dealt with. They can be churned into or ommited from reports. [Learn more](https://google.com).")
        }
    }
    
}



extension TicketListSwiftUIViewForManagement {
    
    
    @ViewBuilder func TicketsToAssessView(_ ticketsToAssess: [FPLightweightIssueTicket]) -> some View {
        ForEach(ticketsToAssess) { ticket in
            FPChevronRowView { 
                viewModel.didTapTicket(ticket)
                
            } children: { 
                HStack {
                    VStack(alignment: .leading) {
                        Text(ticket.issueType.rawValue)
                            .lineLimit(1)
                        
                        Text(dateToString(date: ticket.raisedOn))
                            .foregroundStyle(.secondary)
                            .font(.callout)
                    }
                    Spacer()
                    
                    FPIssueTicketResponseLevelLabel(responseLevel: ticket.responseLevel)
                }
                
            }
        }
    }
    
    
    @ViewBuilder func TicketsToEvaluateView(_ ticketsToEvaluate: [FPLightweightIssueTicket]) -> some View {
        ForEach(ticketsToEvaluate) { ticket in
            FPChevronRowView { 
                viewModel.didTapTicket(ticket)
                
            } children: { 
                HStack {
                    VStack(alignment: .leading) {
                        Text(ticket.issueType.rawValue)
                            .lineLimit(1)
                        
                        Text(dateToString(date: ticket.raisedOn))
                            .foregroundStyle(.secondary)
                            .font(.callout)
                    }
                    Spacer()
                    
                    FPIssueTicketResponseLevelLabel(responseLevel: ticket.responseLevel)
                }
                
            }
        }
    }
    
    
    @ViewBuilder func TicketsUnderProgressView(_ ticketsUnderProgress: [FPLightweightIssueTicket]) -> some View {
        ForEach(ticketsUnderProgress) { ticket in
            FPChevronRowView { 
                viewModel.didTapTicket(ticket)
                
            } children: { 
                HStack {
                    VStack(alignment: .leading) {
                        Text(ticket.issueType.rawValue)
                            .lineLimit(1)
                        
                        Text(dateToString(date: ticket.raisedOn))
                            .foregroundStyle(.secondary)
                            .font(.callout)
                    }
                    Spacer()
                    
                    FPIssueTicketResponseLevelLabel(responseLevel: ticket.responseLevel)
                }
                
            }
        }
    }
    
    
    @ViewBuilder func PastResolvedTicketsView(_ pastResolvedTickets: [FPLightweightIssueTicket]) -> some View {
        ForEach(pastResolvedTickets) { ticket in
            FPChevronRowView { 
                viewModel.didTapTicket(ticket)
                
            } children: { 
                HStack {
                    VStack(alignment: .leading) {
                        Text(ticket.issueType.rawValue)
                            .lineLimit(1)
                        
                        Text(dateToString(date: ticket.raisedOn))
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
