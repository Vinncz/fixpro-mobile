import SwiftUI



/// The SwiftUI View that is bound to be presented in ``AreaManagementViewController``.
struct AreaManagementSwiftUIView: View {
    
    
    /// Two-ways communicator between ``AreaManagementInteractor`` and self.
    @Bindable var viewModel: AreaManagementSwiftUIViewModel
    
    
    @State var shouldShowAreaJoinCode = false
    
    
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
                
                FPChevronRowView{
                    shouldShowAreaJoinCode = true
                } children: { 
                    HStack {
                        Text("Area Join Code")
                        Spacer()
                        Text("Show")
                            .foregroundStyle(.secondary)
                    }
                }
                
                FPChevronRowView{
                    viewModel.routeToManageMembers?()
                } children: { 
                    HStack {
                        Text("Manage Membership")
                        Spacer()
                        Text("0 people")
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Membership controls")
            } footer: {
                Text(LocalizedStringResource("Approve or reject membership to your Area, by selecting approval-required mode as your Join Policy. [Learn more](http://localhost:80)."))
            }
            
            Section {
                FPChevronRowView {
                    viewModel.routeToSLAAndIssueTypesManagement?()
                } children: {
                    VStack(alignment: .leading) {
                        Text("Issue Type Registrar")
                        Text("Manage your Service Level Agreement for a given type of issue.")
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                    }
                }
            } header: {
                Text("Administration")
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
        .sheet(isPresented: $shouldShowAreaJoinCode) { 
            if let endpoint = URL(string: viewModel.areaJoinCodeEndpoint ?? "") {
                FPWebView(contentAddressToPreview: endpoint, previewFault: .constant(.EMPTY), scrollEnabled: true)
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
        }
}
