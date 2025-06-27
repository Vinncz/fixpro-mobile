import SwiftUI
import UniformTypeIdentifiers
import VinUtility



/// The SwiftUI View that is bound to be presented in ``TicketLogViewController``.
struct TicketLogSwiftUIView: View {
    
    
    /// Two-ways communicator between ``TicketLogInteractor`` and self.
    @Bindable var viewModel: TicketLogSwiftUIViewModel
    
    
    @State var globalId = UUID().uuidString
    
    
    @State var pdfToPreview: URL?
    
    
    var body: some View {
        List {
            Section("News") {
                Text(viewModel.log.news)
            }
            
            ForEach(viewModel.log.attachments) { att in 
                if viewModel.log.attachments.first == att {
                    Section("Attachments") {
                        if att.mimetype == UTType.pdf.preferredMIMEType {
                            Button(att.filename) { pdfToPreview = att.hostedOn }
                        } else {
                            HStack {
                                Text(att.filename)
                                Spacer()
                                Text(VUDigitallyConvert(att.filesize, from: .byte, to: .megabyte).formatted(withSymbol: true))
                                    .foregroundStyle(.secondary)
                                    .font(.callout)
                            }
                            .listRowSeparator(.hidden)
                            
                            FPWebView(contentAddressToPreview: att.hostedOn, previewFault: .constant(""), scrollEnabled: false)
                                .frame(minHeight: 200)
                                .background()
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.bottom, VUViewSize.normal.val)
                                .id(globalId + UUID().uuidString)
                        }
                    }
                } else {
                    Section {
                        if att.mimetype == UTType.pdf.preferredMIMEType {
                            Button(att.filename) { pdfToPreview = att.hostedOn }
                        } else {
                            HStack {
                                Text(att.filename)
                                Spacer()
                                Text(VUDigitallyConvert(att.filesize, from: .byte, to: .megabyte).formatted(withSymbol: true))
                                    .foregroundStyle(.secondary)
                                    .font(.callout)
                            }
                            .listRowSeparator(.hidden)
                            
                            FPWebView(contentAddressToPreview: att.hostedOn, previewFault: .constant(""), scrollEnabled: false)
                                .frame(minHeight: 200)
                                .background()
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.bottom, VUViewSize.normal.val)
                                .id(globalId + UUID().uuidString)
                        }
                    } header: {
                        EmptyView()
                    }
                }
            }
            
            Section("Type of log") {
                Text(viewModel.log.type.rawValue)
            }
            
            Section("Committed by") {
                VStack(alignment: .leading) {
                    Text(viewModel.log.issuer.name)
                        .multilineTextAlignment(.leading)
                    if let additionalInformation = viewModel.log.issuer.title {
                        Text(additionalInformation)
                            .foregroundStyle(.secondary)
                            .font(.callout)
                    }
                }
            }
            
            Section("Committed on") {
                HStack {
                    Text("\(Date.parse(viewModel.log.recordedOn)?.formatted(date: .abbreviated, time: .shortened) ?? "Long ago")")
                    Spacer()
                    Text(dateToString(date: (try? Date(viewModel.log.recordedOn, strategy: .iso8601)) ?? .now))
                        .foregroundStyle(.secondary)
                        .font(.callout)
                }
            }
        }
        .sheet(item: $pdfToPreview) { url in
            NavigationStack {
                FPWebView(contentAddressToPreview: url, previewFault: .constant(.EMPTY), scrollEnabled: true)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) { 
                            Button("Download") {
                                viewModel.download?()
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) { 
                            Button("Done") {
                                pdfToPreview = nil
                            }
                        }
                    }
            }
        }
        .refreshable {
            globalId = UUID().uuidString
        }
    }
    
}



//#Preview {
//    @Previewable var viewModel = TicketLogSwiftUIViewModel(log: .init(id: "", 
//                                                                      owningTicketId: "", 
//                                                                      type: .activity, 
//                                                                      issuer: .init(name: "Anna"), 
//                                                                      recordedOn: Date.now.ISO8601Format(), 
//                                                                      news: "Error acquiring assertion: <Error Domain=RBSServiceErrorDomain Code=1 \"((target is not running or doesn't have entitlement com.apple.developer.web-browser-engine.rendering AND target is not running or doesn't have entitlement com.apple.developer.web-browser-engine.networking AND target is not running or doesn't have entitlement com.apple.developer.web-browser-engine.webcontent))\" UserInfo={NSLocalizedFailureReason=((target is not running or doesn't have entitlement com.apple.developer.web-browser-engine.rendering AND target is not running or doesn't have entitlement com.apple.developer.web-browser-engine.networking AND target is not running or doesn't have entitlement com.apple.developer.web-browser-engine.webcontent))}", 
//                                                                      attachments: [
//                                                                        .init(id: "1", filename: "Genericfile.png",
//                                                                              mimetype: "png",
//                                                                              filesize: 2048000,
//                                                                              hostedOn: URL(string: "https://apple.com")!),
//                                                                        .init(id: "2", filename: "Genericfil1e.png", 
//                                                                              mimetype: "png",
//                                                                              filesize: 4090000,
//                                                                              hostedOn: URL(string: "https://apple.com")!)
//                                                                      ], 
//                                                                      actionable: .init(genus: .INERT, species: .INERT)))
//    TicketLogSwiftUIView(viewModel: viewModel)
//}
