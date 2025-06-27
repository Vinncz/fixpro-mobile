import Foundation
import Observation



/// Bridges between ``TicketListsSwiftUIView`` and the ``TicketListsInteractor``.
/// The former invokes and access everything listed within; and the latter supplies the implementation.
@Observable class TicketListsSwiftUIViewModel {
    
    
    var roleContext: FPRoleContext
    
    
    var tickets: [FPLightweightIssueTicket]
    
    
    var didIntendToRefreshTicketList: () async -> Void
    
    
    var didTapTicket: (FPLightweightIssueTicket)->Void
    
    
    var didIntendToOpenNewTicket: () -> Void
    
    
    init(roleContext: FPRoleContext, tickets: [FPLightweightIssueTicket], didIntendToRefreshTicketList: @escaping () -> Void, didTapTicket: @escaping (FPLightweightIssueTicket) -> Void, didIntendToOpenNewTicket: @escaping () -> Void) {
        self.roleContext = roleContext
        self.tickets = tickets
        self.didIntendToRefreshTicketList = didIntendToRefreshTicketList
        self.didTapTicket = didTapTicket
        self.didIntendToOpenNewTicket = didIntendToOpenNewTicket
    }
    
}



extension TicketListsSwiftUIViewModel {
    
    
    var activeTickets: [FPLightweightIssueTicket] {
        tickets.filter { ticket in
            [.open, .inAssessment, .onProgress, .workEvaluation].contains(ticket.status)
        }
    }
    
    
    var pastTickets: [FPLightweightIssueTicket] {
        tickets.filter { ticket in 
            [.closed, .cancelled, .rejected].contains(ticket.status)
        }
    }
    
}



extension TicketListsSwiftUIViewModel {
    
    
    var assignedTickets: [FPLightweightIssueTicket] {
        tickets.filter { ticket in
            [.onProgress, .workEvaluation].contains(ticket.status)
        }
    }
    
    
    var pastContributedTickets: [FPLightweightIssueTicket] {
        tickets.filter { ticket in
            ticket.status == .closed
        }
    }
    
}



extension TicketListsSwiftUIViewModel {
    
    
    var ticketsToAssess: [FPLightweightIssueTicket] {
        tickets.filter { ticket in
            [.open, .inAssessment].contains(ticket.status)
        }
    }
    
    
    var ticketsToEvaluate: [FPLightweightIssueTicket] {
        tickets.filter { ticket in
            ticket.status == .workEvaluation
        }
    }
    
    
    var ticketsUnderProgress: [FPLightweightIssueTicket] {
        tickets.filter { ticket in
            ticket.status == .onProgress
        }
    }
    
    
    var pastResolvedTickets: [FPLightweightIssueTicket] {
        tickets.filter { ticket in
            ![.inAssessment, .onProgress, .open, .workEvaluation].contains(ticket.status)
        }
    }
    
}
