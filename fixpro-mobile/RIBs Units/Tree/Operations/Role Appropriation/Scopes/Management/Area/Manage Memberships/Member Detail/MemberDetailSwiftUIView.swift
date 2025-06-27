import SwiftUI



/// The SwiftUI View that is bound to be presented in ``MemberDetailViewController``.
struct MemberDetailSwiftUIView: View {
    
    
    /// Two-ways communicator between ``MemberDetailInteractor`` and self.
    @Bindable var viewModel: MemberDetailSwiftUIViewModel
    
    
    var body: some View {
        Form {
            Section("Name") {
                Text(viewModel.member.name)
            }
            Section("Role") {
                Text(viewModel.member.role.rawValue)
            }
            if let title = viewModel.member.title {
                Section("Title") {
                    Text(title)
                }
            }
            if viewModel.member.specialties.count > 0 && !viewModel.member.specialties.isEmpty {
                Section("Specialties") {
                    Text(viewModel.member.specialtiesName)
                }
            }
            ForEach(Array(viewModel.member.extras), id: \.key) { pair in
                Section(pair.key) {
                    Text(pair.value)
                }
            }
            Section("Member Since") {
                Text(viewModel.member.memberSince)
            }
        }
        .alert(isPresented: $viewModel.didIntendToRemove) {
            Alert(title: Text("Are you sure?"), 
                  message: Text("Do you wish to remove this member?"), 
                  primaryButton: .cancel(Text("No, cancel")), 
                  secondaryButton: .destructive(Text("Yes, remove")) {
                      viewModel.didRemove?()
                  })
        }
    }
    
}



#Preview {
    @Previewable var viewModel = MemberDetailSwiftUIViewModel(
        member: .init(id: "", 
                      name: "Johny Ive", 
                      role: .member, 
                      specialties: [
                        .init(
                          id: "sa", 
                          name: "Dying", 
                          serviceLevelAgreementDurationHour: "16"
                        ),
                        .init(
                          id: "asd", 
                          name: "Jumping", 
                          serviceLevelAgreementDurationHour: "16"
                        ),
                      ], 
                      capabilities: [], 
                      memberSince: "2025-01-01T19:30:00+00", 
                      extras: [
                        "NIM": "4846514689"
                      ]
                     )
    )
    MemberDetailSwiftUIView(viewModel: viewModel)
}
