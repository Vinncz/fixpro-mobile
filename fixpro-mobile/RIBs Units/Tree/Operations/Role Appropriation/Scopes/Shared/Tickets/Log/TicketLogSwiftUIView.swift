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
                if viewModel.log.attachments.firstIndex(of: att) == 0 {
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
                            
                            AsyncImageWithContextMenu(url: att.hostedOn)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .frame(idealHeight: 216, maxHeight: 216)
                                .background(Color.secondary)
//                                .padding(.bottom, VUViewSize.normal.val)
                                .id(globalId + UUID().uuidString)
                                .listRowInsets(.init())
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
                            
                            AsyncImageWithContextMenu(url: att.hostedOn)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .frame(idealHeight: 216, maxHeight: 216)
                                .background(Color.secondary)
//                                .padding(.bottom, VUViewSize.normal.val)
                                .id(globalId + UUID().uuidString)
                                .listRowInsets(.init())
                        }
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
        .listRowSpacing(0)
        .environment(\.defaultMinListRowHeight, 0)
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



struct AsyncImageWithContextMenu: View {
    
    
    let url: URL
    
    
    @State private var loadedImage: UIImage?
    
    
    @State private var transferableImage: TransferableImage?
    
    
    @State private var shouldShowPreview: Bool = false
    
    
    var body: some View {
        AsyncImage(url: url) { phase in 
            switch phase {
                case .empty:
                    ProgressView()
                    
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()
                        .onAppear {
                            Task {
                                if let data = try? await URLSession.shared.data(from: url),
                                   let uiImage = UIImage(data: data.0) {
                                    self.loadedImage = uiImage
                                    self.transferableImage = TransferableImage(imageData: data.0)
                                }
                            }
                        }
                        .contextMenu {
                            if let uiImage = loadedImage {
                                Button {
                                    UIPasteboard.general.image = uiImage
                                } label: {
                                    Label("Copy", systemImage: "doc.on.doc")
                                }
                                
                                if let transferableImage {
                                    ShareLink(item: transferableImage, preview: SharePreview("Image", image: transferableImage)) {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                }
                                
                                Button {
                                    UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                                } label: {
                                    Label("Save", systemImage: "tray.and.arrow.down")
                                }
                            }
                        }
                    
                case let .failure(error):
                    Image(systemName: "photo.badge.exclamationmark")
                        .onAppear {
                            VULogger.log(tag: .error, error)
                        }
                    
                @unknown default:
                    Image(systemName: "photo.badge.exclamationmark")
            }
        }
        .onTapGesture {
            shouldShowPreview = true
        }
        .sheet(isPresented: $shouldShowPreview) {
            NavigationView {
                FPWebView(contentAddressToPreview: url, previewFault: .constant(""), scrollEnabled: true)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) { 
                            Button("Done") {
                                shouldShowPreview = false
                            }
                        }
                    }
            }
        }
    }
    
}



import UniformTypeIdentifiers

struct TransferableImage: Transferable {
    let imageData: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .image) {
            $0.imageData
        }
    }
}
