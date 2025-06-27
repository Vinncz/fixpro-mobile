import SwiftUI
import VinUtility



extension URL: @retroactive Identifiable {
    public var id: UUID {
        UUID()
    }
}



/// The SwiftUI View that is bound to be presented in ``NewTicketViewController``.
struct NewTicketSwiftUIView: View {
    
    
    /// Two-ways communicator between ``NewTicketInteractor`` and self.
    @Bindable var viewModel: NewTicketSwiftUIViewModel
    
    @Environment(\.dismiss) var dismissAction
    
    @State var shouldShowFileImporter: Bool = false
    @State var fileImporterError: String?
    
    
    var body: some View {
        NavigationStack {
            Form {
                StatedIssueInputView()
                LocationInputView()
                IssueTypesPicker()
                ResponseLevelPickerView()
                SupportiveDocumentsInputView()
                if let errorMsg = viewModel.errorLabel {
                    ValidationLabel(errorMsg)
                }
                Spacer()
                    .frame(minHeight: VUViewSize.cCompact.val / 3)
                    .listRowBackground(Color.clear)
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Opening a new Ticket")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { 
                    Button {
                        viewModel.didIntendToSubmit()
                    } label: {
                        Text("Submit")
                    }
                    .disabled(!validate())
                }
                ToolbarItem(placement: .cancellationAction) { 
                    Button("Cancel", role: .cancel) {
                        dismissAction()
                    }
                }
            }
            .fileImporter(isPresented: $shouldShowFileImporter, allowedContentTypes: [.image, .movie, .archive, .audio, .pdf, .mp3, .heic], allowsMultipleSelection: true) { result in
                switch result {
                    case .success(let fileURLs):
                        fileURLs.forEach { url in
                            _ = url.startAccessingSecurityScopedResource()
                        }
                        Task { @MainActor in
                            viewModel.selectedFiles.append(contentsOf: fileURLs)
                        }
                    case .failure(let error):
                        fileImporterError = error.localizedDescription
                }
            }
        }
    }
    
}



extension NewTicketSwiftUIView {
    
    @ViewBuilder func StatedIssueInputView() -> some View {
        Section {
            TextField("A water dispenser had its gallon leaked, dirtying the floor and caused an elderly to fell.", text: $viewModel.statedIssue, axis: .vertical)
                .lineLimit(4...8)
        } header: {
            Text("Issue statement")
        } footer: {
            Text(LocalizedStringResource("A good description is concise, has causal and effect and explains context of the issue. [Learn more](https://google.com)."))
                .font(.caption)
        }
    }
    
    
    @ViewBuilder func LocationInputView() -> some View {
        Section {
            TextField("Outside fifth floor male restroom, north wing.", text: $viewModel.statedLocation, axis: .vertical)
        } header: {
            Text("Location")
        } footer: {
            Text(LocalizedStringResource("Be specific. By providing a landmark, you help the maintenance crew to locate them quicker."))
        }
    }
    
    
    @ViewBuilder func ResponseLevelPickerView() -> some View {
        Section {
            Picker(selection: $viewModel.suggestedResponseLevel) {
                ForEach(FPIssueTicketResponseLevel.allCases) { responseLevel in 
                    Text(responseLevel.rawValue).tag(responseLevel)
                }
            } label: {
                Text("Response level")
            }
        } header: {
            Text("How pressing is the matter?")
        }
    }
    
    @ViewBuilder func IssueTypesPicker() -> some View {
        Section {
            ForEach(viewModel.issueTypes) { issueType in 
                ToggleableButton(forType: issueType)
            }
        } header: {
            Text("Categorize the issue")
        } footer: {
            Text(
                """
                Select at least one category. If your issue is not listed above, consider asking your area’s management.

                Hours shown on the right measures your management’s service level agreement. You may expect a particular issue to be resolved within the specified time.
                """
            )
        }
    }
    
    
    @ViewBuilder func ToggleableButton(forType type: FPIssueType) -> some View {
        Button {
            viewModel.toggleSelection(for: type)
        } label: {
            HStack {
                Text(type.name)
                Spacer()
                Text("\(type.serviceLevelAgreementDurationHour) hours")
                    .foregroundStyle(.secondary)
                    .font(.callout)
                Image(systemName: "checkmark")
                    .opacity(viewModel.selectedIssueTypes.contains(type) ? 1 : 0)
                    .foregroundStyle(.blue)
            }
        }
        .tint(.primary)
    }
    
    
    @ViewBuilder func SupportiveDocumentsInputView() -> some View {
        Section {
            Button("Choose or open camera", systemImage: "document.badge.plus.fill") {
                shouldShowFileImporter = true
            }
            .listRowBackground(Color.blue.opacity(0.15))
            
            List(viewModel.selectedFiles, id: \.self) { file in 
                NavigationLink(file.lastPathComponent) { 
                    QuickLookPreview(fileURL: file)
                        .interactiveDismissDisabled()
                }
                    .swipeActions { 
                        Button("Delete", role: .destructive) {
                            viewModel.selectedFiles.removeAll { $0 == file }
                        }
                    }
            }
            
        } header: {
            Text("Supportive documents")
        } footer: {
            if let fileImporterError {
                Text("File import error: \(fileImporterError)")
                    .foregroundStyle(.red)
                    .font(.caption)
            } else {
                Text(
                    LocalizedStringResource(
                        """
                        Tap on each of the file’s name to preview them. Swipe leftwards to delete them. [Learn more](https://google.com) about picking a more helpful supportive documents.
                        """
                    )
                )
            }
        }
    }
    
    
    @ViewBuilder func ValidationLabel(_ errorMsg: String) -> some View {
        Section {
            Text(errorMsg)
                .foregroundStyle(.red)
        }
    }
    
}



extension NewTicketSwiftUIView {
    
    
    func validate() -> Bool {
        if !viewModel.statedIssue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !viewModel.statedLocation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !viewModel.selectedFiles.isEmpty
            && !viewModel.selectedIssueTypes.isEmpty
            && viewModel.suggestedResponseLevel != .select
        {
            return true
        }
        return false
    }
    
}



#Preview {
    @Previewable var viewModel = NewTicketSwiftUIViewModel()
    NewTicketSwiftUIView(viewModel: viewModel)
        .onAppear {
            viewModel.errorLabel = "Dieser Test funktioniert noch nicht"
            viewModel.issueTypes = [
                .init(id: "A", name: "Engineering", serviceLevelAgreementDurationHour: "72"),
                .init(id: "C", name: "Housekeeping", serviceLevelAgreementDurationHour: "48"),
                .init(id: "B", name: "HSE", serviceLevelAgreementDurationHour: "24"),
                .init(id: "D", name: "Security", serviceLevelAgreementDurationHour: "12")
            ]
        }
}
