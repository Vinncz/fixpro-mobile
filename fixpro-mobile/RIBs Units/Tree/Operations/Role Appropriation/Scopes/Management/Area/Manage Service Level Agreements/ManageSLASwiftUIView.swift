import SwiftUI



/// The SwiftUI View that is bound to be presented in ``ManageSLAViewController``.
struct ManageSLASwiftUIView: View {
    
    
    /// Two-ways communicator between ``ManageSLAInteractor`` and self.
    @Bindable var viewModel: ManageSLASwiftUIViewModel
    
    
    var body: some View {
        Form {
            Section {
                HStack {
                    TextField(viewModel.respondSLA, text: $viewModel.respondSLA)
                        .keyboardType(.numberPad)
                    Spacer()
                    Text("hours")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Duration to Respond")
            } footer: {
                Text("Specifies the amount of time that management has, to assess a ticket before its rating takes a hit.")
            }
            
            Section {
                HStack {
                    TextField(viewModel.autoCloseSLA, text: $viewModel.autoCloseSLA)
                        .keyboardType(.numberPad)
                    Spacer()
                    Text("hours")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Duration to Auto Close")
            } footer: {
                Text(LocalizedStringResource("Specifies how long a ticket under **owner evaluation** get auto-closed."))
            }
            
            Section {
                ForEach(Array(viewModel.issueTypes.enumerated()), id: \.element.id) { index, issueType in
                    HStack {
                        Text("\(issueType.name)")
                            .foregroundStyle(.secondary)
                        Spacer()
                        TextField("\(issueType.serviceLevelAgreementDurationHour)", text: $viewModel.issueTypes[index].serviceLevelAgreementDurationHour)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                        Text("hours")
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Duration per Categories")
            } footer: {
                Text(LocalizedStringResource("Specifies the commitment enforced to solving a particular type of issues within the specified duration."))
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
}



#Preview {
    @Previewable var viewModel = {
        var vm = ManageSLASwiftUIViewModel()
        vm.issueTypes = [
            .init(id: "1", name: "Dying", serviceLevelAgreementDurationHour: "2"),
            .init(id: "2", name: "Light", serviceLevelAgreementDurationHour: "3"),
            .init(id: "3", name: "Transition", serviceLevelAgreementDurationHour: "4"),
        ]
        return vm
    }()
    
    ManageSLASwiftUIView(viewModel: viewModel)
}
