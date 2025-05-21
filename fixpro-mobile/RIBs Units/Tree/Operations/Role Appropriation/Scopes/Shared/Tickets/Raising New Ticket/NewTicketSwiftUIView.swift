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
                ResponseLevelPickerView()
                SupportiveDocumentsInputView()
                IssueCharacteristicInputView()
                ExecutiveSummaryInputView()
                if let errorMsg = viewModel.errorLabel {
                    ValidationLabel(errorMsg)
                }
                Spacer()
                    .frame(minHeight: VUViewSize.cCompact.val / 2)
                    .listRowBackground(Color.clear)
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Raising an issue ticket")
            .toolbar {
                ToolbarItem(placement: .bottomBar) { 
                    Button {
                        viewModel.didIntendToSubmit()
                    } label: {
                        Text("Raise my issue")
                            .padding(.vertical, VUViewSize.small.val)
                            .padding(.horizontal, VUViewSize.xxBig.val * 4)
                    }
                        .padding(.top, VUViewSize.small.val)
                        .overlay(Rectangle().fill(.clear))
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.errorLabel != nil)
                }
                ToolbarItem(placement: .topBarLeading) { 
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
            Text("What happened? • Required")
        } footer: {
            Text(LocalizedStringResource("A good description is concise, has causal and effect, and explains the context of the issue. [Learn more](https://google.com).\n"))
        }
        .keyboardDismissableByTappingNearlyAnywhere()
    }
    
    
    @ViewBuilder func LocationInputView() -> some View {
        Section {
            TextField("Outside fifth floor male restroom, north wing.", text: $viewModel.statedLocation, axis: .vertical)
                .lineLimit(2...8)
        } header: {
            Text("Where did you find it? • Required")
        } footer: {
            Text(LocalizedStringResource("Be specific. By providing a landmark, you could help the maintenance crew to locate the issue quicker.\n"))
        }
        .keyboardDismissableByTappingNearlyAnywhere()
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
            Text("How pressing is the matter? • Required")
        } footer: {
            Text("Some severity are prioritized over others.\n")
        }
    }
    
    @ViewBuilder func IssueCharacteristicInputView() -> some View {
        Section {
            ForEach(viewModel.issueTypes) { issueType in 
                ToggleableButton(forType: issueType)
            }
        } header: {
            Text("Which of these categories? • Required")
        } footer: {
            Text("Select only those that best describe your issue. Selecting too many may cause your ticket to be delayed or even rejected.\n")
        }
    }
    
    
    @ViewBuilder func ToggleableButton(forType type: FPIssueType) -> some View {
        Button {
            viewModel.toggleSelection(for: type)
        } label: {
            HStack {
                Text(type.name)
                Spacer()
                Text("Approx. \(type.serviceLevelAgreementDurationHour) hours")
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
            Text("Supportive documents • Required")
        } footer: {
            if let fileImporterError {
                Text("File import error: \(fileImporterError)")
                    .foregroundStyle(.red)
                    .font(.caption)
            } else {
                Text(LocalizedStringResource("Tap the name of the file to preview, and swipe leftwards to delete. Selecting a helpful supportive documents helps management to understand your issue better [Learn more](https://google.com).\n"))
            }
        }
    }
    
    
    @ViewBuilder func ExecutiveSummaryInputView() -> some View {
        Section {
            TextField("", text: $viewModel.executiveSummary, axis: .vertical)
                .lineLimit(1...2)
        } header: {
            Text("Summary in one sentence • Optional")
        } footer: {
            Text("Catchy or serious summary may catch the attention of management sooner.\n")
        }
    }
    
    
    @ViewBuilder func ValidationLabel(_ errorMsg: String) -> some View {
        Section {
            Text(errorMsg)
                .foregroundStyle(.red)
        }
    }
    
}



#Preview {
    @Previewable var viewModel = NewTicketSwiftUIViewModel()
    NewTicketSwiftUIView(viewModel: viewModel)
        .onAppear {
            viewModel.errorLabel = "Dieser Test funktioniert noch nicht"
        }
}
