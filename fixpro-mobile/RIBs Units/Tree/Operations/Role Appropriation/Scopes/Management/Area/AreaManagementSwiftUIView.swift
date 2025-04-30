import SwiftUI



/// The SwiftUI View that is bound to be presented in ``AreaManagementViewController``.
struct AreaManagementSwiftUIView: View {
    
    
    /// Two-ways communicator between ``AreaManagementInteractor`` and self.
    @Bindable var viewModel: AreaManagementSwiftUIViewModel
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Area Name")
                    Spacer()
                    Text("Bali Indah Beach")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("General Information")
            }
            
            Section {
                Picker("Join Policy", selection: Binding(get: { 
                    viewModel.joinPolicy ?? .CLOSED
                }, set: { newValue in
                    viewModel.didUpdateJoinPolicy?(newValue)
                })) {
                    Text("Open").tag(FPAreaJoinPolicy.OPEN)
                    Text("Approval-required").tag(FPAreaJoinPolicy.APPROVAL_NEEDED)
                    Text("Closed").tag(FPAreaJoinPolicy.CLOSED)
                }
                
                DisclosureGroup("Area Join Code", isExpanded: .constant(false)) { 
                    Button("Area Join Code") { viewModel.routeToAreaJoinCode?() }
                }.tint(.secondary)
                
                DisclosureGroup(isExpanded: .constant(false)) { 
                    Button("Pending Membership") { viewModel.routeToPendingMembership?() }
                } label: {
                    HStack {
                        Text("Pending Membership")
                        Spacer()
                        Text("0 requests")
                            .foregroundStyle(.secondary)
                    }
                }
                .tint(.secondary)
                
                DisclosureGroup(isExpanded: .constant(false)) { 
                    Button("Manage Members") { viewModel.routeToManageMembers?() }
                } label: {
                    HStack {
                        Text("Manage Members")
                        Spacer()
                        Text("0 people")
                            .foregroundStyle(.secondary)
                    }
                }
                .tint(.secondary)
                
            } header: {
                Text("Membership controls")
                
            } footer: {
                Text(LocalizedStringResource("Approve or reject membership to your Area, by selecting approval-required mode as your Join Policy. [Learn more](http://localhost:80)."))
            }
            
            Section {
                DisclosureGroup(isExpanded: Binding(get: { 
                    false
                }, set: { _ in
                    viewModel.routeToStatisticView?()
                })) {} 
                label: {
                    VStack(alignment: .leading) {
                        Text("Export Tickets as PDF")
                        Text("Select among \(viewModel.ticketCount ?? 0) ticket(s) to process")
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                    }
                }
                .tint(.secondary)
            } header: {
                Text("Statistics")
            } footer: {
                Text(LocalizedStringResource("Learn all the trends happening to your Area, by churning Tickets into actionable data."))
            }
        }
    }
    
}



#Preview {
    @Previewable var viewModel = AreaManagementSwiftUIViewModel()
    AreaManagementSwiftUIView(viewModel: viewModel)
        .onAppear {
            viewModel.joinPolicy = .OPEN
            viewModel.didUpdateJoinPolicy = { newPolicy in
                viewModel.joinPolicy = newPolicy
                print(newPolicy)
            }
            viewModel.routeToPendingMembership = {
                print("Pending")
            }
        }
}
