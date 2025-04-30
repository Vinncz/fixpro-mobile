import SwiftUI



/// The SwiftUI View that is bound to be presented in ``TicketReportViewController``.
struct TicketReportSwiftUIView: View {
    
    
    /// Two-ways communicator between ``TicketReportInteractor`` and self.
    @Bindable var viewModel: TicketReportSwiftUIViewModel
    
    
    var body: some View {
        NavigationView {
            FPWebView(contentAddressToPreview: viewModel.urlToReport, previewFault: .constant(.EMPTY), scrollEnabled: true)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) { 
                        Button("Done") {
                            viewModel.didIntendToDismiss?()
                        }
                    }
                }
        }
    }
    
}



#Preview {
    @Previewable var viewModel = TicketReportSwiftUIViewModel()
    TicketReportSwiftUIView(viewModel: viewModel)
}
