import SwiftUI



/// The SwiftUI View that is bound to be presented in ``UpdateContributingViewController``.
struct UpdateContributingSwiftUIView: View {
    
    
    /// Two-ways communicator between ``UpdateContributingInteractor`` and self.
    @Bindable var viewModel: UpdateContributingSwiftUIViewModel
    
    
    @State var statedIssue: String = .EMPTY
    @State var supportiveDocuments: [URL] = []
    @State var updateType: FPTicketLogType = .select
    
    
    var body: some View {
        NavigationView {
            Form {
                StatedIssueInputSectionView(statedIssue: $statedIssue)
                SupportiveDocumentInputSectionView(supportiveDocuments: $supportiveDocuments)
                if let authContext = viewModel.authorizationContext {
                    UpdateTypeInputSectionView(roleContext: authContext, updateType: $updateType)
                }
            }
            .navigationTitle("Contributing an update")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { 
                    Button("Cancel") {
                        viewModel.didIntendToCancel?()
                    }
                }
                ToolbarItem(placement: .confirmationAction) { 
                    Button("Done") {
                        viewModel.didIntendToSubmit?(statedIssue, supportiveDocuments, updateType)
                    }
                    .disabled(
                        !(!statedIssue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        && !supportiveDocuments.isEmpty
                        && updateType != .select)
                    )
                }
            }
            .interactiveDismissDisabled()
        }
    }
    
}



struct StatedIssueInputSectionView: View {
    
    
    @Binding var statedIssue: String
    
    
    var body: some View {
        Section {
            TextField("Replaced the burnt down lightbulb.", text: $statedIssue, axis: .vertical)
                .lineLimit(4...8)
        } header: {
            Text("News")
        } footer: {
            Text(LocalizedStringResource("A good update connects the pain points with action(s) that resolve or may resolve them. [Learn more](https://google.com)."))
        }
    }
    
}



struct SupportiveDocumentInputSectionView: View {
    
    
    @State var shouldShowFileImporter: Bool = false
    
    
    @State var fileImporterError: String?
    
    
    @Binding var supportiveDocuments: [URL]
    
    
    var body: some View {
        Section {
            Button("Choose or open camera", systemImage: "document.badge.plus.fill") {
                shouldShowFileImporter = true
            }
            .listRowBackground(Color.blue.opacity(0.15))
            
            List(supportiveDocuments, id: \.self) { file in 
                NavigationLink(file.lastPathComponent) { 
                    QuickLookPreview(fileURL: file)
                        .interactiveDismissDisabled()
                }
                    .swipeActions { 
                        Button("Delete", role: .destructive) {
                            supportiveDocuments.removeAll { $0 == file }
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
                    .multilineTextAlignment(.leading)
            } else {
                Text(LocalizedStringResource("Tap the name of the file to preview, and swipe leftwards to delete. Selecting a helpful supportive documents helps management to understand your issue better [Learn more](https://google.com)."))
            }
        }
        .fileImporter(isPresented: $shouldShowFileImporter, allowedContentTypes: [.image, .movie, .archive, .audio, .pdf, .mp3, .heic], allowsMultipleSelection: true) { result in
            switch result {
                case .success(let fileURLs):
                    fileURLs.forEach { url in
                        _ = url.startAccessingSecurityScopedResource()
                    }
                    Task { @MainActor in
                        supportiveDocuments.append(contentsOf: fileURLs)
                    }
                case .failure(let error):
                    fileImporterError = error.localizedDescription
            }
        }
    }
    
}



struct UpdateTypeInputSectionView: View {
    
    
    var roleContext: FPRoleContext
    
    
    @Binding var updateType: FPTicketLogType
    
    
    var body: some View {
        Section {
            Picker(selection: $updateType) {
                ForEach(determineAvailableTypes()) { logType in 
                    Text(logType.shorthand).tag(logType)
                }
            } label: {
                Text("Type of contribution")
                    .truncationMode(.tail)
            }
            
        } header: {
            Text("Administration")
            
        } footer: {
            Text(
                """
                Use the _work progress_ to share your latest update, and use the _work evaluation request_ to finalize your contributions.

                Once you’ve requested an evaluation, you and your colleagues will be unable to add any more progress until the evaluation is done.

                [Learn more](https://google.com) about a ticket lifecycle.
                """
            )
        }
    }
    
    
    private func determineAvailableTypes() -> [FPTicketLogType] {
        switch roleContext.role {
            case .management:
                return [.select, .activity, .timeExtension ]
            case .crew:
                return if roleContext.capabilities.contains(.IssueSupervisorApproval) {
                    [.select, .workProgress, .workEvaluationRequest, .workEvaluation, .timeExtension]
                } else {
                    [.select, .workProgress, .workEvaluationRequest, .timeExtension]
                }
            default: 
                return [.select]
        }
    }
    
}



#Preview {
    @Previewable var viewModel = UpdateContributingSwiftUIViewModel()
    UpdateContributingSwiftUIView(viewModel: viewModel)
}
