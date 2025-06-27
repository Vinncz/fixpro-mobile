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
                    Text(viewModel.areaName ?? "Unnamed Area")
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
                    viewModel.routeToManageMemberships?()
                } children: { 
                    Text("Manage Membership")
                }
            } header: {
                Text("Membership controls")
            } footer: {
                Text(LocalizedStringResource("Approve or reject membership to your Area, by selecting approval-required mode as your Join Policy. [Learn more](http://localhost:80)."))
            }
            
            Section {
                FPChevronRowView {
                    viewModel.routeToIssueTypesRegistrar?()
                } children: {
                    Text("Issue Types Registrar")
                }
                FPChevronRowView {
                    viewModel.routeToManageSLA?()
                } children: {
                    Text("Manage Service Level Agreements")
                }
            } header: {
                Text("Administration")
            } footer: {
                Text(LocalizedStringResource(stringLiteral: "Manage a variety of *issue categories* that can be handled via FixPro."))
            }
            
            Section {
                DisclosureGroup(isExpanded: Binding(get: { 
                    false
                }, set: { _ in
                    viewModel.routeToStatisticsAndReports?()
                })) {} 
                label: {
                    Text("Statistics and reports")
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
