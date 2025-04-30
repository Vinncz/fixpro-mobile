import SwiftUI



/// The SwiftUI View that is bound to be presented in ``CrewNewWorkLogViewController``.
struct CrewNewWorkLogSwiftUIView: View {
    
    
    /// Two-ways communicator between ``CrewNewWorkLogInteractor`` and self.
    @Bindable var viewModel: CrewNewWorkLogSwiftUIViewModel
    
    
    @State var shouldShowFileImporter: Bool = false
    @State var fileImporterError: String?
    
    
    var body: some View {
        NavigationView {
            Form {
                StatedIssueInputView()
                IssueCharacteristicInputView()
                SupportiveDocumentsInputView()
                if !viewModel.validationLabel.isEmpty {
                    ValidationLabel(viewModel.validationLabel)
                }
            }
                .scrollDismissesKeyboard(.immediately)
                .toolbarTitleDisplayMode(.inline)
                .navigationTitle("Contributing an Update")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { 
                        Button("Cancel") {
                            viewModel.didIntendToDismiss?()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) { 
                        Button("Done") {
                            viewModel.didIntendToAddWorkLog?()
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



extension CrewNewWorkLogSwiftUIView {
    
    
    @ViewBuilder func StatedIssueInputView() -> some View {
        Section {
            TextField("A water dispenser had its gallon leaked, dirtying the floor and caused an elderly to fell.", text: $viewModel.workDescription, axis: .vertical)
                .lineLimit(4...8)
        } header: {
            Text("What has been done? • Required")
        } footer: {
            Text(LocalizedStringResource("A good report is chronological and ties what's been done with the reason to do so. [Learn more](https://google.com)."))
        }
    }
    
    
    @ViewBuilder func IssueCharacteristicInputView() -> some View {
        Section {
            Picker(selection: $viewModel.logType) {
                ForEach(FPTIcketLogType.allCases.filter{ [.select, .workProgress, .workEvaluationRequest].contains($0) }) { logType in 
                    Text(logType.rawValue).tag(logType)
                }
            } label: {
                Text("Update type")
            }
        } header: {
            Text("Log Entry Administration • Required")
        }
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
                Text(LocalizedStringResource("Tap the name of the file to preview, and swipe leftwards to delete. Selecting a helpful supportive documents helps management to understand your issue better [Learn more](https://google.com)."))
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



#Preview {
    @Previewable var viewModel = CrewNewWorkLogSwiftUIViewModel()
    CrewNewWorkLogSwiftUIView(viewModel: viewModel)
}
