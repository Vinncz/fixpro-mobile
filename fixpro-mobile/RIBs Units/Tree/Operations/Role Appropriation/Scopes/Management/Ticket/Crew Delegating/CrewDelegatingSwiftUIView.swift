import SwiftUI



/// The SwiftUI View that is bound to be presented in ``CrewDelegatingViewController``.
struct CrewDelegatingSwiftUIView: View {
    
    
    /// Two-ways communicator between ``CrewDelegatingInteractor`` and self.
    @Bindable var viewModel: CrewDelegatingSwiftUIViewModel
    
    
    var body: some View {
        NavigationView {
            Form {
                if !viewModel.validationLabel.isEmpty {
                    Section("Validation") {
                        Text(viewModel.validationLabel)
                            .foregroundStyle(.red)
                    }
                }
                
                Section {
                    TextField("Gallon replacement for the 5th floor dispenser.", text: $viewModel.executiveSummary, axis: .vertical)
                        .lineLimit(2...4)
                } header: {
                    Text("Executive summary")
                } footer: {
                    Text("Help your colleagues by telling them what's wrong and what needs to be done.")
                }
                
                Section {
                    ForEach(viewModel.availablePersonnel) { personnel in 
                        ToggleableButton(forPersonnel: personnel)
                    }
                } header: {
                    Text("Available Personnel")
                } footer: {
                    Text(LocalizedStringResource(
                        """
                        Tap the name of the person you’d want to delegate this Ticket to, and tap “done”. 

                        By doing so, you are sharing your responsibility with the selected personnel to tend to this Ticket. This action will notify them.

                        If you can’t find some personnel, its probably due to them not having the same specialty as this ticket's type. [Troubleshoot the issue](https://google.com).
                        """
                    ))
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { 
                    Button("Cancel") {
                        viewModel.didIntendToDismiss?()
                    }
                }
                ToolbarItem(placement: .confirmationAction) { 
                    Button("Save") {
                        viewModel.didIntendToDelegate?()
                    }
                }
            }
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Delegating Ticket")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    
    @ViewBuilder func ToggleableButton(forPersonnel personnel: FPPerson) -> some View {
        Button {
            viewModel.toggleSelection(for: personnel)
        } label: {
            HStack {
                Text(personnel.name)
                Spacer()
                Text(personnel.moreInformation[.title] ?? "")
                    .foregroundStyle(.secondary)
                    .font(.callout)
                Image(systemName: "checkmark")
                    .opacity(viewModel.selectedPersonnel.contains(personnel) ? 1 : 0)
                    .foregroundStyle(.blue)
            }
        }
        .tint(.primary)
    }
    
}


#Preview {
    @Previewable var viewModel = CrewDelegatingSwiftUIViewModel()
    CrewDelegatingSwiftUIView(viewModel: viewModel)
        .onAppear {
            var A = FPPerson(id: "A", 
                          name: "Kodok", 
                          role: .member, 
                             speciality: [.engineering], 
                          memberSince: .now)
            A.moreInformation[.title] = "Janitor"
            
            
            viewModel.availablePersonnel = [
                A,
                .init(id: "B", 
                      name: "Dog", 
                      role: .member, 
                      speciality: [.engineering], 
                      memberSince: .now,
                     ),
                .init(id: "C", 
                      name: "Birb", 
                      role: .member, 
                      speciality: [.engineering], 
                      memberSince: .now)
            ]
        }
}
