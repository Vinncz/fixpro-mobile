import SwiftUI



/// The SwiftUI View that is bound to be presented in ``TicketReportViewController``.
struct TicketReportSwiftUIView: View {
    
    
    /// Two-ways communicator between ``TicketReportInteractor`` and self.
    @Bindable var viewModel: TicketReportSwiftUIViewModel
    
    
    var body: some View {
        NavigationView {
            FPWebView(contentAddressToPreview: viewModel.urlToReport, previewFault: .constant(.EMPTY), scrollEnabled: true)
                .scrollDismissesKeyboard(.immediately)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) { 
                        Button("Done") {
                            viewModel.didIntendToDismiss?()
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) { 
                        Button("Download") {
                            viewModel.didIntendToDownload?()
                        }
                    }
                }
                .navigationTitle("Print View")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
}



#Preview {
    @Previewable var viewModel = TicketReportSwiftUIViewModel(urlToReport: URL(string: "http://localhost")!)
    TicketReportSwiftUIView(viewModel: viewModel)
}
