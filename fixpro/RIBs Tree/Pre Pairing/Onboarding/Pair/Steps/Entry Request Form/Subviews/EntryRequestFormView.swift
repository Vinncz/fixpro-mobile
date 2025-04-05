import SwiftUI

struct EntryRequestFormView: View {
    
    @Bindable var viewModel: EntryRequestFormViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.fieldsAndAnswers.keys.map({$0}), id: \.self) { field in
                Section("\(field)") {
                    TextField("...", text: Binding(
                        get: { viewModel.fieldsAndAnswers[field] ?? "" },
                        set: { viewModel.fieldsAndAnswers[field] = $0 }
                    ))
                    .onTapGesture {
                        viewModel.filloutValidationLabel = .EMPTY
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Copy", role: .cancel) {
                            copyToClipboard(viewModel.fieldsAndAnswers[field] ?? "")
                        }
                        .tint(.blue)
                    }
                    .swipeActions(edge: .leading) {
                        Button("Empty", role: .cancel) {
                            viewModel.fieldsAndAnswers[field] = ""
                        }
                        .tint(.red)
                    }
                }
            }
            
            if !viewModel.filloutValidationLabel.isEmpty {
                Section("Warning") {
                    VStack {
                        Text(viewModel.filloutValidationLabel)
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }
    
}

#Preview {
    @Previewable @State var viewModel = EntryRequestFormViewModel()
    VStack {
        EntryRequestFormView(viewModel: viewModel)
            .onAppear {
                viewModel.fieldsAndAnswers = [
                    "Name": ""
                    ,"Phone number": ""
                ]
                viewModel.filloutValidationLabel = ""
            }
        Button("Show validation label") {
            viewModel.filloutValidationLabel = "THIS IS A WARNING"
        }
        Button("Hide validation label") {
            viewModel.filloutValidationLabel = ""
        }
        Text(viewModel.fieldsAndAnswers["Phone number"] ?? "UNK")
        Text(viewModel.fieldsAndAnswers["Name"] ?? "UNK")
    }
}
