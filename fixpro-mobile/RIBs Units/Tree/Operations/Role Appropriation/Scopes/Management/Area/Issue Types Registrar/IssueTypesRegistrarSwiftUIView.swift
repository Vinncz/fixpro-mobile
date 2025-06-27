import SwiftUI



/// The SwiftUI View that is bound to be presented in ``IssueTypesRegistrarViewController``.
struct IssueTypesRegistrarSwiftUIView: View {
    
    
    /// Two-ways communicator between ``IssueTypesRegistrarInteractor`` and self.
    @Bindable var viewModel: IssueTypesRegistrarSwiftUIViewModel
    
    
    var body: some View {
        Form {
            Section {
                Button {
                    viewModel.didIntendToAddIssueTypes = true
                } label: {
                    Label("New Category", systemImage: "plus")
                }
                ForEach(viewModel.issueTypes) { it in 
                    HStack {
                        Text(it.name)
                        Spacer()
                        Text("\(it.serviceLevelAgreementDurationHour) hours")
                            .foregroundStyle(.secondary)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel.didRemoveIssueType?(it)
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
                }
            } header: {
                Text("All Categories")
            } footer: {
                Text("Swipe leftwards to unlist a category. Tickets that are currently open will not get affected--and new tickets can no longer use unlisted categories.")
            }
        }
        .refreshable {
            try? await viewModel.didRefresh?()
        }
        .sheet(isPresented: $viewModel.didIntendToAddIssueTypes) {
            NewIssueTypeView(viewModel: viewModel)
                .presentationDetents([.medium, .large])
                .interactiveDismissDisabled()
                .scrollDismissesKeyboard(.immediately)
        }
        .alert(isPresented: $viewModel.shouldShowSuccessAlert) {
            Alert(title: Text("Successfully registered new issue type"), dismissButton: .default(Text("Done")))
        }
        .alert(isPresented: $viewModel.shouldShowFailureAlert) {
            Alert(title: Text("Failed to remove an issue type"), dismissButton: .default(Text("Done")))
        }
    }
    
}



fileprivate struct NewIssueTypeView: View {
    
    
    @Bindable var viewModel: IssueTypesRegistrarSwiftUIViewModel
    
    
    @State var issueTypeName: String = .EMPTY
    
    
    @State var issueTypeSLA: String = .EMPTY
    
    
    var body: some View {
        NavigationView {
            Form {
                Section("Name") {
                    TextField("Security", text: $issueTypeName)
                }
                
                Section {
                    HStack {
                        TextField("48", text: $issueTypeSLA)
                            .keyboardType(.numberPad)
                        Text("hours")
                            .foregroundStyle(.secondary)
                    }
                } header:{
                    Text("Service Level Agreement Duration")
                } footer: {
                    Text(LocalizedStringResource(
                        """
                        A *service level agreement* reflects your commitment in solving an issue within an expectable and reasonable pace.

                        Once set, everyone will rightfully expect that this kind of category will be resolved wihtin the specified time.
                        """
                    ))
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { 
                    Button("Register") {
                        viewModel.didMakeNewIssueType?(issueTypeName, issueTypeSLA)
                    }
                    .disabled(!validateInputs(name: issueTypeName, duration: issueTypeSLA))
                }
                ToolbarItem(placement: .cancellationAction) { 
                    Button("Cancel") {
                        viewModel.didIntendToAddIssueTypes = false
                    }
                }
            }
            .navigationTitle("New Issue Type")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
}



fileprivate func validateInputs(name: String, duration: String) -> Bool {
    if name.trimmingCharacters(in: .whitespacesAndNewlines).count > 0
        && duration.trimmingCharacters(in: .whitespacesAndNewlines).count > 0
    {
        return true
    }
    
    return false
}



#Preview {
    @Previewable var viewModel = IssueTypesRegistrarSwiftUIViewModel()
    IssueTypesRegistrarSwiftUIView(viewModel: viewModel)
}
