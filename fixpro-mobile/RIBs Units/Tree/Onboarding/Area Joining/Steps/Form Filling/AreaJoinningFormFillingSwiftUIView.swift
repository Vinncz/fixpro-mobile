import SwiftUI
import VinUtility



/// The SwiftUI View that is bound to be presented in ``AreaJoinningFormFillingViewController``.
struct AreaJoinningFormFillingSwiftUIView: View {
    
    
    /// Two-ways communicator between ``AreaJoinningFormFillingInteractor`` and self.
    @Bindable var viewModel: AreaJoinningFormFillingSwiftUIViewModel
    
    
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
                            VUCopyToClipboard(viewModel.fieldsAndAnswers[field] ?? "")
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
    @Previewable var viewModel = AreaJoinningFormFillingSwiftUIViewModel()
    AreaJoinningFormFillingSwiftUIView(viewModel: viewModel)
}
