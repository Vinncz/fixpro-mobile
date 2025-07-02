import SwiftUI
import UniformTypeIdentifiers
import VinUtility



/// The SwiftUI View that is bound to be presented in ``WorkEvaluatingViewController``.
struct WorkEvaluatingSwiftUIView: View {
    
    
    /// Two-ways communicator between ``WorkEvaluatingInteractor`` and self.
    @Bindable var viewModel: WorkEvaluatingSwiftUIViewModel
    
    
    @State var shownLog: FPTicketLog? = nil
    
    
    var filteredLogs: [FPTicketLog] {
        Array(viewModel.ticket.logs.filter({ [.workProgress, .workEvaluationRequest].contains($0.type) }).prefix(4))
    }
    
    
    var body: some View {
        NavigationView {
            Form {
                EvaluationSection(viewModel: viewModel)
                Divider()
                    .listRowInsets(.init())
                    .listRowBackground(Color.clear)
                TicketLogCurationSection(viewModel: viewModel, shownLog: $shownLog)
                    .onAppear {
                        if let log = filteredLogs.first {
                            shownLog = log
                        }
                    }
            }
            .environment(\.defaultMinListRowHeight, 0)
            .listRowSpacing(0)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { 
                    Button("Cancel") {
                        viewModel.didIntendToCancel?()
                    }
                }
                ToolbarItem(placement: .confirmationAction) { 
                    Button("Evaluate") {
                        Task {
                            try await viewModel.didIntendToEvaluate?()
                        }
                    }
                    .disabled(
                        !(viewModel.resolve != .Select)
                    )
                }
            }
            .navigationTitle("Work evaluating")
            .navigationBarTitleDisplayMode(.inline)
            
        }
        .environment(viewModel)
    }
    
}



fileprivate struct EvaluationSection: View {
    
    
    @Bindable var viewModel: WorkEvaluatingSwiftUIViewModel
    
    
    @State var shouldShowFileImporter: Bool = false
    
    
    var body: some View {
        Section {
            Picker("This evaluation request is", selection: $viewModel.resolve) {
                ForEach(EvaluationResolve.allCases) { r in 
                    Text(r.rawValue)
                }
            }
            .frame(height: 24)
            if viewModel.component.authorizationContext.role == .management {
                Toggle(isOn: $viewModel.requireOwnerEvaluation) { 
                    Text("Request ticket owner's evaluation")
                }
                .disabled(viewModel.ticket.issuer.model.role != .member)
                .frame(height: 24)
            }
            TextField("Remarks..", text: $viewModel.remarks, axis: .vertical)
                .lineLimit(2...4)
        } header: {
            VStack(alignment: .leading, spacing: VUViewSize.xSmall.val) {
                Text("Evaluation")
                    .font(.headline)
                Text("Decide what's next for this ticket")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(.primary)
        } footer: {
            Text(
                """
                Use the *remark field* to elaborate about the work result; whether it has achieved its objective. 
                
                You can also point out where something fell short, so your colleagues can have another go at fixing them.
                
                Should the ticket owner's role is other than a member, you cannot request for their evaluation.
                """
            )
        }
        
        Section {
            Button("Choose or open camera", systemImage: "document.badge.plus.fill") {
                shouldShowFileImporter = true
            }
            .listRowBackground(Color.blue.opacity(0.15))
            .fileImporter(isPresented: $shouldShowFileImporter, allowedContentTypes: [.image, .movie, .archive, .audio, .pdf, .mp3, .heic], allowsMultipleSelection: true) { result in
                switch result {
                    case .success(let fileURLs):
                        fileURLs.forEach { url in
                            _ = url.startAccessingSecurityScopedResource()
                        }
                        Task { @MainActor in
                            viewModel.supportiveDocuments.append(contentsOf: fileURLs)
                        }
                    case .failure(let error):
                        VULogger.log(tag: .error, error)
                }
            }
            
            List(viewModel.supportiveDocuments, id: \.self) { file in 
                NavigationLink(file.lastPathComponent) { 
                    QuickLookPreview(fileURL: file)
                        .interactiveDismissDisabled()
                }
                    .swipeActions { 
                        Button("Delete", role: .destructive) {
                            viewModel.supportiveDocuments.removeAll { $0 == file }
                        }
                    }
            }
        } header: {
            Text("Supportive Documents")
        } footer: {
            Text("Tap on each of the file’s name to preview them. Swipe leftwards to delete them. [Learn more](https://google.com) about picking a more helpful supportive documents.")
        }
    }
    
}



fileprivate struct TicketLogCurationSection: View {
    
    
    @Bindable var viewModel: WorkEvaluatingSwiftUIViewModel
    
    
    @Binding var shownLog: FPTicketLog?
    
    
    @State var pdfToPreview: URL?
    
    
    var filteredLogs: [FPTicketLog] {
        Array(viewModel.ticket.logs.filter({ [.workProgress, .workEvaluationRequest].contains($0.type) }).prefix(4))
    }
    
    
    var body: some View {
        if shownLog != nil {
            SegmentedPicker()
            TicketLogDetail()
        } else {
            Section {
                ContentUnavailableView(
                    "Unable to Preview Log", 
                    systemImage: "xmark", 
                    description: Text("There are no logs which match the required criteria.")
                )
            }
        }
    }
    
    
    @ViewBuilder func SegmentedPicker() -> some View {
        Section {
            Picker("Examine logs", selection: $shownLog) { 
                ForEach(filteredLogs) { log in 
                    Text(log.type.shorthand).tag(log)
                }
            }
            .pickerStyle(.segmented)
            .listRowInsets(.init())
            .listRowBackground(Color.clear)
        } header: {
            VStack(alignment: .leading, spacing: VUViewSize.xSmall.val) {
                Text("Logs Curation")
                    .font(.headline)
                Text("Examine recent logs to evaluate better")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(.primary)
        } footer: {
            Text("Switch between logs to see the timeline of events.")
        }
    }
    
    
    @ViewBuilder func TicketLogDetail() -> some View {
        if let log = shownLog {
            Section {
                VStack(alignment: .leading) {
                    Text(log.issuer.name)
                    if let title = log.issuer.title {
                        Text(title)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }
                Text(log.recordedOn)
                
                
            } header: {
                Text("Issuer")
            }
            
            Section("News") {
                Text(log.news)
            }
            
            ForEach(log.attachments) { att in 
                if log.attachments.first == att {
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
                                .listRowInsets(.init())
                        }
                    } header: {
                        EmptyView()
                    }
                }
            }
            
            Section("Type of update") {
                Text(log.type.rawValue)
            }
            .sheet(item: $pdfToPreview) { url in
                NavigationStack {
                    FPWebView(contentAddressToPreview: url, previewFault: .constant(.EMPTY), scrollEnabled: true)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) { 
                                Button("Download") {
                                    
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
            
        }
    }
    
}



//#Preview {
//    @Previewable var viewModel = WorkEvaluatingSwiftUIViewModel(ticket: .init(
//        id: "", 
//        issueTypes: [
//            .init(id: "IT1", name: "Engineering", serviceLevelAgreementDurationHour: "72"),
//            .init(id: "IT2", name: "Housekeeping", serviceLevelAgreementDurationHour: "48")
//        ], 
//        responseLevel: .normal, 
//        raisedOn: "\(Date.now.formatted())", 
//        status: .onProgress, 
//        statedIssue: "Lorem ipsum", 
//        location: .init(
//            reportedLocation: "Lift entrance, 5th floor", 
//            gpsCoordinates: .init(latitude: 0, longitude: 0)
//        ), 
//        supportiveDocuments: [
//            .init(id: "SD1", filename: "Preview.png", mimetype: "image/png", filesize: 2_000_000, hostedOn: URL(string: "https://picsum.photos/1200/1200")!)
//        ], 
//        issuer: VUExtrasPreservingDecodable<FPPerson>(from: .init(
//            id: "P1", 
//            name: "Andrew Benjamin", 
//            role: .member, 
//            specialties: [], 
//            capabilities: [], 
//            memberSince: "\(Date.now.ISO8601Format())"
//        )), 
//        logs: [
//            .init(
//                id: "L1", 
//                owningTicketId: "T1", 
//                type: .workEvaluationRequest, 
//                issuer: .init(
//                    id: "P1", 
//                    name: "Andrew Benjamin", 
//                    role: .member, 
//                    title: "Head Janitor",
//                    specialties: [], 
//                    capabilities: [], 
//                    memberSince: "\(Date.now.ISO8601Format())"
//                ), 
//                recordedOn: "\(Date.now.ISO8601Format())", 
//                news: "Ticket was opened.", 
//                attachments: [
//                    .init(id: "F1", filename: "Rickroll.mp4", mimetype: "video/mp4", filesize: 2_000_000, hostedOn: URL(string: "https://picsum.photos/1200/1200")!)
//                ], 
//                actionable: .init(
//                    genus: .SEGUE, 
//                    species: .TICKET_LOG, 
//                    destination: "L1"
//                )
//            ),
//            .init(
//                id: "L2", 
//                owningTicketId: "T1", 
//                type: .workProgress, 
//                issuer: .init(
//                    id: "P1", 
//                    name: "Andrew Benjamin", 
//                    role: .member, 
//                    specialties: [], 
//                    capabilities: [], 
//                    memberSince: "\(Date.now.ISO8601Format())"
//                ), 
//                recordedOn: "\(Date.now.ISO8601Format())", 
//                news: "Ticket was opened.", 
//                attachments: [], 
//                actionable: .init(
//                    genus: .SEGUE, 
//                    species: .TICKET_LOG, 
//                    destination: "L1"
//                )
//            )
//        ], 
//        handlers: []
//    ))
//    WorkEvaluatingSwiftUIView(viewModel: viewModel)
//}
