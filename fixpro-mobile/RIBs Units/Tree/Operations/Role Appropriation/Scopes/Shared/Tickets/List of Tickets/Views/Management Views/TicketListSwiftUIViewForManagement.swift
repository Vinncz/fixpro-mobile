import SwiftUI
import VinUtility


fileprivate enum TicketListTab: String, CaseIterable, Hashable, Identifiable {
    case toAssess = "To Assess"
    case evaluate = "Evaluate"
    case ongoing = "Ongoing"
    case past = "Past"
    
    var id: Self { self }
}



struct TicketListSwiftUIViewForManagement: View {
    
    
    var viewModel: TicketListsSwiftUIViewModel
    
    
    @State fileprivate var activeTab: TicketListTab = .toAssess
    
    
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
            case .toAssess:
                SectionToAssess()
            case .evaluate:
                SectionEvaluate()
            case .ongoing:
                SectionOngoing()
            case .past:
                SectionPast()
        }
    }
    
}



extension TicketListSwiftUIViewForManagement {
    
    @ViewBuilder func SectionToAssess() -> some View {
        if viewModel.ticketsToAssess.count <= 0 {
            Section {
                HStack(alignment: .top) {
                    ContentUnavailableView("No Tickets", 
                                           systemImage: "ticket", 
                                           description: Text("There are currently no ticket waiting to be assessed.\n\nWhen you (or anyone) open one,\nthey'll show up here."))
                }
                .frame(height: 350)
                .padding(.top, VUViewSize.xxxBig.val * 3)
                .listRowInsets(.init())
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(Color.clear)
            }
            
        } else {
            Section {
                TicketsToAssessView(viewModel.ticketsToAssess)
            } header: {
                Text("Open tickets in need of attention")
            } footer: {
                Text(LocalizedStringResource("These Tickets represents ongoing operational problems in Area you manage. [Learn more](https://google.com)."))
            }
        }
    }
    
    @ViewBuilder func SectionEvaluate() -> some View {
        if viewModel.ticketsToEvaluate.count <= 0 {
            Section {
                HStack(alignment: .top) {
                    ContentUnavailableView("No Tickets", 
                                           systemImage: "checkmark.circle.badge.xmark", 
                                           description: Text("There are currently no ticket which require your evaluation."))
                }
                .frame(height: 350)
                .padding(.top, VUViewSize.xxxBig.val * 3)
                .listRowInsets(.init())
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(Color.clear)
            }
            
        } else {
            Section {
                TicketsToEvaluateView(viewModel.ticketsToEvaluate)
            } header: {
                Text("Tickets awaiting evaluation")
            } footer: {
                Text(LocalizedStringResource("These are Tickets which were reported as ‘solved’ by your maintenance crew colleague. For quality control, you may want to assess them. [Learn more](https://google.com)."))
            }
        }
    }
    
    @ViewBuilder func SectionOngoing() -> some View {
        if viewModel.ticketsUnderProgress.count <= 0 {
            Section {
                HStack(alignment: .top) {
                    ContentUnavailableView("No Tickets", 
                                           systemImage: "person.2.badge.gearshape", 
                                           description: Text("There are currently no ticket being worked on right now."))
                }
                .frame(height: 350)
                .padding(.top, VUViewSize.xxxBig.val * 3)
                .listRowInsets(.init())
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(Color.clear)
            }
            
        } else {
            Section {
                TicketsUnderProgressView(viewModel.ticketsUnderProgress)
            } header: {
                Text("Tickets under progress")
            } footer: {
                Text("These are Tickets that have been delegated to your crew colleagues. They aren't yet resolved, but when they are, your colleagues can request for your evaluation. [Learn more](https://google.com).")
            }
        }
    }
    
    @ViewBuilder func SectionPast() -> some View {
        if viewModel.pastResolvedTickets.count <= 0 {
            Section {
                HStack(alignment: .top) {
                    ContentUnavailableView("No Tickets", 
                                           systemImage: "clock.badge.checkmark", 
                                           description: Text("There are currently no tickets that have been solved, rejected, or cancelled.\n\nWhen there are, they'll show up here."))
                }
                .frame(height: 350)
                .padding(.top, VUViewSize.xxxBig.val * 3)
                .listRowInsets(.init())
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(Color.clear)
            }
            
        } else {
            Section {
                PastResolvedTicketsView(viewModel.pastResolvedTickets)
            } header: {
                Text("Past resolved tickets")
            } footer: {
                Text("These are Tickets that you and your colleagues have dealt with. They can be churned into or ommited from reports. [Learn more](https://google.com).")
            }
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
                        Text(ticket.issueTypes.map{ $0.name }.coalesce())
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
    
    
    @ViewBuilder func TicketsToEvaluateView(_ ticketsToEvaluate: [FPLightweightIssueTicket]) -> some View {
        ForEach(ticketsToEvaluate) { ticket in
            FPChevronRowView { 
                viewModel.didTapTicket(ticket)
                
            } children: { 
                HStack {
                    VStack(alignment: .leading) {
                        Text(ticket.issueTypes.map{ $0.name }.coalesce())
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
    
    
    @ViewBuilder func TicketsUnderProgressView(_ ticketsUnderProgress: [FPLightweightIssueTicket]) -> some View {
        ForEach(ticketsUnderProgress) { ticket in
            FPChevronRowView { 
                viewModel.didTapTicket(ticket)
                
            } children: { 
                HStack {
                    VStack(alignment: .leading) {
                        Text(ticket.issueTypes.map{ $0.name }.coalesce())
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
    
    
    @ViewBuilder func PastResolvedTicketsView(_ pastResolvedTickets: [FPLightweightIssueTicket]) -> some View {
        ForEach(pastResolvedTickets) { ticket in
            FPChevronRowView { 
                viewModel.didTapTicket(ticket)
                
            } children: { 
                HStack {
                    VStack(alignment: .leading) {
                        Text(ticket.issueTypes.map{ $0.name }.coalesce())
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
    
}

#Preview {
    Form {
        TicketListSwiftUIViewForManagement(viewModel: .init(
            roleContext: .init(role: .management, capabilities: [], specialties: []), 
            tickets: [], 
            didIntendToRefreshTicketList: {}, 
            didTapTicket: {_ in}, 
            didIntendToOpenNewTicket: {}
        ))
    }
}
