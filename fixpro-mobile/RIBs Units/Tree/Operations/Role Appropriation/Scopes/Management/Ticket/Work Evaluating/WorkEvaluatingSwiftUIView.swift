import SwiftUI



struct InlineImageListView: View {
    
    
    var urls: [URL]
    
    
    @State var reloadId = UUID()
    
    
    var body: some View {
        ForEach(urls) { url in
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 200, height: 200)
                        .background(.regularMaterial)
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                case .success(let image):
                    image
                        .resizable()
                        .frame(width: 200, height: 200)
                        .background(.regularMaterial)
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                case .failure:
                    Image(systemName: "arrow.clockwise")
                        .frame(width: 200, height: 200)
                        .background(.regularMaterial)
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onTapGesture {
                            reloadId = UUID()
                        }
                @unknown default:
                    EmptyView()
                }
            }
            .id(reloadId)
        }
    }
    
}



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
//                                InlineImageListView(urls: log.attachment.map { $0.hostedOn })
                                ForEach(log.attachment.map { $0.hostedOn }) { url in 
                                    FPWebView(contentAddressToPreview: url, previewFault: .constant(.EMPTY), scrollEnabled: false)
                                        .frame(width: 200, height: 200)
                                        .background(.regularMaterial)
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                        
                    } header: {
                        Text(dateToString(date: log.recordedOn))
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
                
                Section {
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
        .onAppear {
            viewModel.workProgressLogs = [
                .init(id: "yes", 
                      owningTicketId: "", 
                      type: .workProgress, 
                      issuer: .init(name: "Dawg"), 
                      recordedOn: .now, 
                      news: "Lorem ipsum dolor sit amet", 
                      attachment: [
                        .init(filename: "Genericfile.png", hostedOn: URL(string: "https://picsum.photos/200")!)
                      ], 
                      actionable: .init(genus: .INERT, species: .INERT)),
                .init(id: "nope", 
                      owningTicketId: "", 
                      type: .workProgress, 
                      issuer: .init(name: "Dawg"), 
                      recordedOn: .now.addingTimeInterval(-1 * (24 * 3600)), 
                      news: "Lorem ipsum dolor sit amet", 
                      attachment: [
                        .init(filename: "Genericfile.png", hostedOn: URL(string: "https://picsum.photos/200")!)
                      ], 
                      actionable: .init(genus: .INERT, species: .INERT)),
                .init(id: "nope", 
                      owningTicketId: "", 
                      type: .workProgress, 
                      issuer: .init(name: "Dawg"), 
                      recordedOn: .now.addingTimeInterval(-1 * (24 * 3600)), 
                      news: "Lorem ipsum dolor sit amet", 
                      attachment: [
                        .init(filename: "Genericfile.png", hostedOn: URL(string: "https://picsum.photos/200")!)
                      ], 
                      actionable: .init(genus: .INERT, species: .INERT)),
                .init(id: "nope", 
                      owningTicketId: "", 
                      type: .workProgress, 
                      issuer: .init(name: "Dawg"), 
                      recordedOn: .now.addingTimeInterval(-1 * (24 * 3600)), 
                      news: "Lorem ipsum dolor sit amet", 
                      attachment: [
                        .init(filename: "Genericfile.png", hostedOn: URL(string: "https://picsum.photos/200")!)
                      ], 
                      actionable: .init(genus: .INERT, species: .INERT))
            ]
        }
}
