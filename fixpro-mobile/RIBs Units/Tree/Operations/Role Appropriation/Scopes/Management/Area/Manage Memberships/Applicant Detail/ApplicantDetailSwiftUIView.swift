import SwiftUI
import VinUtility



/// The SwiftUI View that is bound to be presented in ``ApplicantDetailViewController``.
struct ApplicantDetailSwiftUIView: View {
    
    
    /// Two-ways communicator between ``ApplicantDetailInteractor`` and self.
    @Bindable var viewModel: ApplicantDetailSwiftUIViewModel
    
    
    var body: some View {
        Form {
            Section("Applied on") {
                Text(viewModel.applicant.submittedOn)
            }
            ForEach(viewModel.applicant.formAnswer, id: \.self) { answer in
                Section(answer.fieldLabel) {
                    Text(answer.fieldValue)
                }
            }
        }
        .sheet(isPresented: $viewModel.didIntendToApprove) { 
            ApprovalDetailView(viewModel: viewModel)
                .presentationDetents([.medium, .large])
        }
        .alert("Confirm rejecting this applicant?", isPresented: $viewModel.didIntendToReject) { 
            HStack {
                Button("No, cancel", role: .cancel) {
                    viewModel.didIntendToReject = false
                }
                Button("Yes, Reject", role: .destructive) {
                    viewModel.didReject?()
                }
            }
        }
    }
    
}



fileprivate struct ApprovalDetailView: View {
    
    
    @Bindable var viewModel: ApplicantDetailSwiftUIViewModel
    
    
    @State var role: FPTokenRole = .member
    
    
    @State var title: String = .EMPTY
    
    
    @State var specialties: [FPIssueType] = []
    
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker(selection: $role) { 
                        ForEach(FPTokenRole.allCases) { role in
                            Text(role.rawValue)
                        }
                    } label: { 
                        Text("Admit as")
                    }
                } header: {
                    Text("Role")
                } footer: {
                    Text("Some options may be available only to specific roles.")
                }
                
                if role != .member {
                    Section("Title") {
                        TextField("Chief of Engineering", text: $title)
                    }
                }
                
                if role == .crew {
                    if viewModel.specialties.count > 0 {
                        Section {
                            ForEach(viewModel.specialties, id: \.self) { specialty in 
                                MultiSelectPickerRow {
                                    Text(specialty.name)
                                } callback: { isCurrentlyChecked in
                                    if specialties.contains(specialty) {
                                        specialties.removeAll { $0 == specialty }
                                        return false
                                    } else {
                                        specialties.append(specialty)
                                        return true
                                    }
                                }
                            }
                        } header: {
                            Text("Specialties")
                        } footer: {
                            Text("Crews with matching specialties can be delegated to handle tickets where others can’t.")
                        }
                    } else {
                        Section {
                            ContentUnavailableView("No Issue Types", 
                                                   systemImage: "tray", 
                                                   description: Text("Continuing may lead to unexpected behavior. It's highly recommended to register some issue types first.")) 
                            .padding(.top, VUViewSize.xxxBig.val)
                        } header: {
                            Text("Specialties")
                        } footer: {
                            Text("Crews with matching specialties can be delegated to handle tickets where others can’t.")
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { 
                    Button("Cancel") {
                        viewModel.didIntendToApprove = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) { 
                    Button("Approve") {
                        viewModel.didApprove?(role, title, specialties)
                    }
                    .disabled(shouldAllowForSubmission())
                }
            }
            .navigationTitle("Admission Confirmation")
            .navigationBarTitleDisplayMode(.inline)
        }
        .interactiveDismissDisabled(role != .member)
    }
    
    
    func shouldAllowForSubmission() -> Bool {
        if role == .crew {
            return specialties.isEmpty
        }
        
        return false
    }
    
}



fileprivate struct MultiSelectPickerRow<Children: View>: Identifiable, View {
    
    
    var id = UUID()
    
    
    @State var isSelected: Bool = false
    
    
    @ViewBuilder var children: Children
    
    
    var callback: (Bool)->Bool
    
    
    var body: some View {
        HStack {
            children
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundStyle(.blue)
            } else {
                EmptyView()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isSelected = callback(isSelected)
        }
    }
    
}



#Preview {
    @Previewable var viewModel = ApplicantDetailSwiftUIViewModel(applicant: .init(id: "", formAnswer: [
        .init(fieldLabel: "Name", fieldValue: "Kodok")
    ], submittedOn: "2025-01-01T19:30:00+00"))
    ApplicantDetailSwiftUIView(viewModel: viewModel)
        .onAppear {
            viewModel.specialties = [
                .init(id: "1", name: "Engineering", serviceLevelAgreementDurationHour: "12"),
                .init(id: "2", name: "HSE", serviceLevelAgreementDurationHour: "12"),
                .init(id: "3", name: "Plumbing", serviceLevelAgreementDurationHour: "12")
            ]
        }
}
