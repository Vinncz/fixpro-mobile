import SwiftUI
import VinUtility



/// The SwiftUI View that is bound to be presented in ``StatisticsAndReportsViewController``.
struct StatisticsAndReportsSwiftUIView: View {
    
    
    /// Two-ways communicator between ``StatisticsAndReportsInteractor`` and self.
    @Bindable var viewModel: StatisticsAndReportsSwiftUIViewModel
    
    
    @State var shouldShowReport: StatisticsAndReportsBundle? = nil
    
    
    @State var shouldShowTicketSummarization: StatisticsAndReportsBundle? = nil
    
    
    @State var previewURLRequest: URLRequest?
    
    
    var body: some View {
        if viewModel.bundles.count > 0 {
            Form {
                ForEach(viewModel.bundles) { bundle in 
                    Section("\(bundle.month) \(bundle.year)") {
                        FPChevronRowView { 
                            shouldShowReport = bundle
                        } children: { 
                            Text("Report")
                        }

                        FPChevronRowView { 
                            shouldShowTicketSummarization = bundle
                        } children: { 
                            Text("Ticket Summarization")
                        }
                    }
                }
            }
            .sheet(item: $shouldShowReport) { bundle in
                NavigationView {
                    if let previewURLRequest {
                        FPWebViewWithURLRequest(request: previewURLRequest, previewFault: .constant(""), scrollEnabled: true)
                            .toolbar {
                                ToolbarItem(placement: .topBarLeading) { 
                                    Button("Refresh") {
                                        Task {
                                            self.previewURLRequest = await self.viewModel.urlRequest(from: bundle.periodicReportLink)
                                        }
                                    }
                                }
                                ToolbarItem(placement: .confirmationAction) { 
                                    Button("Done") {
                                        self.shouldShowReport = nil
                                        self.previewURLRequest = nil
                                    }
                                }
                            }
                    } else {
                        VStack {
                            Spacer()
                            ContentUnavailableView("Periodic Report is Loading..", 
                                                   systemImage: "clock.badge", 
                                                   description: Text("Once its loaded, we'll show it here."))
                            Spacer()
                        }
                        .background(Color(.systemGroupedBackground))
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) { 
                                Button("Refresh") {
                                    Task {
                                        self.previewURLRequest = await self.viewModel.urlRequest(from: bundle.ticketSummarizationLink)
                                    }
                                }
                            }
                            ToolbarItem(placement: .confirmationAction) { 
                                Button("Done") {
                                    self.shouldShowTicketSummarization = nil
                                    self.previewURLRequest = nil
                                }
                            }
                        }
                    }
                }
                .interactiveDismissDisabled()
                .onAppear {
                    Task {
                        self.previewURLRequest = await self.viewModel.urlRequest(from: bundle.periodicReportLink)
                    }
                }
            }
            .sheet(item: $shouldShowTicketSummarization) { bundle in
                NavigationView {
                    if let previewURLRequest {
                        FPWebViewWithURLRequest(request: previewURLRequest, previewFault: .constant(""), scrollEnabled: true)
                            .toolbar {
                                ToolbarItem(placement: .topBarLeading) { 
                                    Button("Refresh") {
                                        Task {
                                            self.previewURLRequest = await self.viewModel.urlRequest(from: bundle.ticketSummarizationLink)
                                        }
                                    }
                                }
                                ToolbarItem(placement: .confirmationAction) { 
                                    Button("Done") {
                                        self.shouldShowTicketSummarization = nil
                                        self.previewURLRequest = nil
                                    }
                                }
                            }
                    } else {
                        VStack {
                            Spacer()
                            ContentUnavailableView("Ticket Summarization is Loading..", 
                                                   systemImage: "clock.badge", 
                                                   description: Text("Once its loaded, we'll show it here."))
                            Spacer()
                        }
                        .background(Color(.systemGroupedBackground))
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) { 
                                Button("Refresh") {
                                    Task {
                                        self.previewURLRequest = await self.viewModel.urlRequest(from: bundle.ticketSummarizationLink)
                                    }
                                }
                            }
                            ToolbarItem(placement: .confirmationAction) { 
                                Button("Done") {
                                    self.shouldShowTicketSummarization = nil
                                    self.previewURLRequest = nil
                                }
                            }
                        }
                    }
                }
                .interactiveDismissDisabled()
                .onAppear {
                    Task {
                        self.previewURLRequest = await self.viewModel.urlRequest(from: bundle.ticketSummarizationLink)
                    }
                }
            }
            .refreshable {
                try? await viewModel.didIntendToRefresh?()
            }
        } else {
            VStack {
                ContentUnavailableView("No Statistics to Show", 
                                       systemImage: "tray", 
                                       description: Text("When you have used FixPro for a while, reports will be available for you to access."))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .background(Color(.systemGroupedBackground))
        }
        
    }
    
}



//#Preview {
//    @Previewable var viewModel = {
//        let vm = StatisticsAndReportsSwiftUIViewModel()
//        vm.bundles = [
////            .init(month: "January", year: "2025", periodicReportLink: URL("http://localhost")!, ticketSummarizationLink: URL("http://localhost")!)
//        ]
//        return vm
//    }()
//    StatisticsAndReportsSwiftUIView(viewModel: viewModel)
//}
