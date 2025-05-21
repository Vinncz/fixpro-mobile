import SwiftUI



/// The SwiftUI View that is bound to be presented in ``WorkEvaluatingViewController``.
struct WorkEvaluatingSwiftUIView: View {
    
    
    /// Two-ways communicator between ``WorkEvaluatingInteractor`` and self.
    @Bindable var viewModel: WorkEvaluatingSwiftUIViewModel
    
    
    var body: some View {
        NavigationView {
            Form {
                ForEach(viewModel.workProgressLogs) { log in
                    Section {
                        Text(log.news)
                        
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(log.attachments.map { $0.hostedOn }) { url in 
                                    FPWebView(contentAddressToPreview: url, previewFault: .constant(.EMPTY), scrollEnabled: false)
                                        .frame(width: 200, height: 200)
                                        .background(.regularMaterial)
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                        
                    } header: {
                        Text(dateToString(date: (try? Date(log.recordedOn, strategy: .iso8601)) ?? .now))
                    } footer: {
                        Text(LocalizedStringResource(
                            """
                            Submitted by **\(log.issuer.name)**
                            • \(log.type.rawValue)
                            """
                        ))
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }
                
                if !viewModel.validationMessage.isEmpty {
                    Section("Validation") {
                        Text(viewModel.validationMessage)
                            .foregroundStyle(.red)
                    }
                }
                
                Section {
                    TextField("Rejection reason", text: $viewModel.rejectionReason, axis: .vertical)
                        .lineLimit(2...4)
                    Button("Reject work report", role: .destructive) {
                        viewModel.didIntendToReject?()
                    }
                } header: {
                    Text("Danger Zone")
                } footer: {
                    Text("""
                        Rejecting is a way to signal disatisfaction that something could be done more against this ticket.
                        
                        Rejecting will also notify all handlers associated with this ticket.
                        """)
                }
            }
                .scrollDismissesKeyboard(.immediately)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { 
                        Button("Cancel") {
                            viewModel.didIntendToDismiss?()
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) { 
                        Button("Approve") {
                            viewModel.didIntendToApprove?()
                        }
                    }
                }
                .navigationTitle("Evaluate works")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
    
}



#Preview {
    @Previewable var viewModel = WorkEvaluatingSwiftUIViewModel()
    WorkEvaluatingSwiftUIView(viewModel: viewModel)
//        .onAppear {
//            viewModel.workProgressLogs = [
//                .init(id: "yes", 
//                      owningTicketId: "", 
//                      type: .workProgress, 
//                      issuer: .init(name: "Dawg"), 
//                      recordedOn: Date.now.ISO8601Format(), 
//                      news: "Lorem ipsum dolor sit amet", 
//                      attachments: [
////                        .init(filename: "Genericfile.png", mimetype: "png",
////                              filesize: "2048", hostedOn: URL(string: "https://picsum.photos/200")!)
//                      ], 
//                      actionable: .init(genus: .INERT, species: .INERT)),
//                .init(id: "nope", 
//                      owningTicketId: "", 
//                      type: .workProgress, 
//                      issuer: .init(name: "Dawg"), 
//                      recordedOn: Date.now.addingTimeInterval(-1 * (24 * 3600)).ISO8601Format(), 
//                      news: "Lorem ipsum dolor sit amet", 
//                      attachments: [
////                        .init(filename: "Genericfile.png", mimetype: "png",
////                              filesize: "2048", hostedOn: URL(string: "https://picsum.photos/200")!)
//                      ], 
//                      actionable: .init(genus: .INERT, species: .INERT)),
//                .init(id: "nope", 
//                      owningTicketId: "", 
//                      type: .workProgress, 
//                      issuer: .init(name: "Dawg"), 
//                      recordedOn: Date.now.addingTimeInterval(-1 * (24 * 3600)).ISO8601Format(), 
//                      news: "Lorem ipsum dolor sit amet", 
//                      attachments: [
////                        .init(filename: "Genericfile.png", mimetype: "png",
////                              filesize: "2048", hostedOn: URL(string: "https://picsum.photos/200")!)
//                      ], 
//                      actionable: .init(genus: .INERT, species: .INERT)),
//                .init(id: "nope", 
//                      owningTicketId: "", 
//                      type: .workProgress, 
//                      issuer: .init(name: "Dawg"), 
//                      recordedOn: Date.now.addingTimeInterval(-1 * (24 * 3600)).ISO8601Format(), 
//                      news: "Lorem ipsum dolor sit amet", 
//                      attachments: [
////                        .init(filename: "Genericfile.png", mimetype: "png",
////                              filesize: "2048", hostedOn: URL(string: "https://picsum.photos/200")!)
//                      ], 
//                      actionable: .init(genus: .INERT, species: .INERT))
//            ]
//        }
}
