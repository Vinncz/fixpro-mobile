import SwiftUI
import VinUtility



struct Wrapper<K, V>: Identifiable {
    var id = UUID()
    var key: K
    var value: V
}


/// The SwiftUI View that is bound to be presented in ``TicketDetailViewController``.
struct TicketDetailSwiftUIView: View {
    
    
    /// Two-ways communicator between ``TicketDetailInteractor`` and self.
    @Bindable var viewModel: TicketDetailSwiftUIViewModel
    
    
    @State var previewFault: String?
    
    
    var body: some View {
        Form {
            SummaryView(viewModel: viewModel)
            StatedIssueView(viewModel: viewModel)
            ReportedLocationView(viewModel: viewModel)
            SupportiveDocumentListView(viewModel: viewModel)
            LogListView(viewModel: viewModel)
            HandlerListView(viewModel: viewModel)
        }
        .refreshable { try? await viewModel.didIntedToRefresh?() }
        .alert("Are you sure?", isPresented: $viewModel.shouldShowCancellationAlert, actions: { 
            Button("Cancel", role: .cancel) {
                viewModel.shouldShowCancellationAlert = false
            }
            Button("Confirm", role: .destructive) {
                Task { try await viewModel.didCancelTicket?() }
            }
        }, message: { 
            Text("Do you wish to cancel your ticket?")
        })
        .scrollDismissesKeyboard(.immediately)
        .sheet(isPresented: $viewModel.shouldShowPrintView) {
            if let ticket = viewModel.ticket, 
               let previewURL = URL(string: "\(viewModel.baseURL?.absoluteString ?? "")/ticket/\(ticket.id)/print-view") 
            {
                NavigationView {
                    FPWebView(contentAddressToPreview: previewURL, previewFault: $previewFault, scrollEnabled: true)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) { 
                                Button("Download") {
                                    
                                }
                            }
                            ToolbarItem(placement: .confirmationAction) { 
                                Button("Done") {
                                    viewModel.shouldShowPrintView = false
                                }
                            }
                        }
                        .navigationTitle("Print View")
                        .navigationBarTitleDisplayMode(.inline)
                }
            } else {
                ContentUnavailableView("Print View Is Unavailable", 
                                       systemImage: "xmark", 
                                       description: Text(previewFault ?? "Unknown error."))
            }
        }
        .sheet(isPresented: $viewModel.shouldShowRejectionAlert) {
            TicketRejectionView(viewModel: viewModel)
        }
    }
    
}



// MARK: -- Subviews

fileprivate struct SummaryView: Identifiable, View {
    
    
    @Bindable var viewModel: TicketDetailSwiftUIViewModel
    
    
    var body: some View {
        Section {
            HStack {
                Text("Issue type")
                Spacer()
                if let ticket = viewModel.ticket {
                    Text(ticket.issueTypes.map{ $0.name }.coalesce())
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                } else {
                    Text("XXX XXXXXXX XXXX")
                        .redacted(reason: [.placeholder])
                }
            }
            HStack {
                Text("Response level")
                Spacer()
                if let ticket = viewModel.ticket {
                    Text(ticket.responseLevel.rawValue)
                        .foregroundStyle(.secondary)
                } else {
                    Text("XXXXXX")
                        .redacted(reason: [.placeholder])
                }
            }
            HStack {
                Text("Raised on")
                Spacer()
                if let ticket = viewModel.ticket {
                    Text("\(Date.parse(ticket.raisedOn)?.formatted(date: .abbreviated, time: .shortened) ?? "")")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                } else {
                    Text("XXXX-XXXXX")
                        .redacted(reason: [.placeholder])
                }
            }
            HStack {
                Text("Current status")
                Spacer()
                if let ticket = viewModel.ticket {
                    Text(ticket.status.rawValue)
                        .foregroundStyle(ticket.status.color)
                        .multilineTextAlignment(.trailing)
                } else {
                    Text("XXXXXX")
                        .redacted(reason: [.placeholder])
                }
            }
        } header: {
            Text("Administration")
        } footer: {
            Text("The status above changes each time a log entry gets added. [Learn more](https://google.com) about ticket statuses.")
        }
    }
    
    
    var id = UUID()
    
}



fileprivate struct StatedIssueView: Identifiable, View {
    
    
    @Bindable var viewModel: TicketDetailSwiftUIViewModel
    
    
    var body: some View {
        Section {
            if let ticket = viewModel.ticket {
                Text(ticket.statedIssue)
                    .multilineTextAlignment(.leading)
            } else {
                Text("XXX XXXXXXX XXXX XX XXXX XXXXXX XXXX XXXXX XXXXXX XXXXXXXX X XXXXX")
                    .redacted(reason: [.placeholder])
            }
        } header: {
            Text("Stated Issue")
        } footer: {
            Text("The claim above outlines the problem or concern as described by the person who reported it.")
        }
    }
    
    
    var id = UUID()
    
}



fileprivate struct ReportedLocationView: Identifiable, View {
    
    
    @Bindable var viewModel: TicketDetailSwiftUIViewModel
    
    
    @State var mapLocation: FPGPSLocation?
    
    
    var body: some View {
        Section {
            if let ticket = viewModel.ticket {
                Text(ticket.location.reportedLocation)
                    .multilineTextAlignment(.leading)
                Button {
                    mapLocation = ticket.location.gpsCoordinates
                } label: {
                    Label("Open on maps", systemImage: "map")
                }
                .sheet(item: $mapLocation) { location in
                    NavigationView {
                        LocationMapView(latitude: location.latitude, longitude: location.longitude, label: "")
                            .toolbar {
                                ToolbarItem(placement: .confirmationAction) { 
                                    Button("Done") {
                                        mapLocation = nil
                                    }
                                }
                                ToolbarItem(placement: .topBarLeading) { 
                                    Button("Copy coordinates") {
                                        VUCopyToClipboard("\(location.latitude), \(location.longitude)")
                                    }
                                }
                            }
                    }
                    .interactiveDismissDisabled()
                    .presentationDetents([.medium])
                }
            } else {
                Text("XXX XXXXXXX XXXX XX XXXX")
                    .redacted(reason: [.placeholder])
                Button {} label: {
                    Label("Open on maps", systemImage: "map")
                        .foregroundStyle(.secondary)
                }
                .disabled(true)
            }
        } header: {
            Text("Reported Location")
        }
    }
    
    
    var id = UUID()
    
}



fileprivate struct SupportiveDocumentListView: Identifiable, View {
    
    
    @Bindable var viewModel: TicketDetailSwiftUIViewModel
    
    
    @State var previewedSupportiveDocument: FPSupportiveDocument?
    
    
    var body: some View {
        Section {
            if let ticket = viewModel.ticket {
                ForEach(ticket.supportiveDocuments, id: \.self) { document in
                    FPChevronRowView {
                        previewedSupportiveDocument = document
                    } children: {
                        VStack(alignment: .leading) {
                            Text(document.filename)
                            Text(VUDigitallyConvert(document.filesize, from: .byte, to: .megabyte).formatted(withSymbol: true))
                                .foregroundStyle(.secondary)
                                .font(.callout)
                        }
                    }
                    .sheet(item: $previewedSupportiveDocument) { document in
                        NavigationView {
                            FPWebView(contentAddressToPreview: document.hostedOn, previewFault: .constant(""), scrollEnabled: true)
                                .toolbar {
                                    ToolbarItem(placement: .confirmationAction) { 
                                        Button("Done") {
                                            previewedSupportiveDocument = nil
                                        }
                                    }
                                    ToolbarItem(placement: .topBarLeading) { 
                                        Button("Copy link") {
                                            VUCopyToClipboard(document.hostedOn)
                                        }
                                    }
                                }
                                .navigationTitle(document.filename)
                                .navigationBarTitleDisplayMode(.inline)
                        }
                        .interactiveDismissDisabled()
                        .presentationDetents([.medium, .large])
                    }
                }
            } else {
                VStack(alignment: .leading) {
                    Text("XXX XXXXXXX XXXX XX XXXX XXXXXX")
                        .redacted(reason: [.placeholder])
                    Text("Size unknown")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                }
            }
        } header: {
            Text("Supportive Documents")
        }
    }
    
    
    var id = UUID()
    
}



fileprivate struct LogListView: Identifiable, View {
    
    
    @Bindable var viewModel: TicketDetailSwiftUIViewModel
    
    
    var body: some View {
        Section {
            if let ticket = viewModel.ticket {
                ForEach(ticket.logs, id: \.self) { log in
                    if case .INERT = log.actionable.genus, case .INERT = log.actionable.species {
                        VStack(alignment: .leading) {
                            Text(log.news)
                                .lineLimit(1)
                            Text("\(Date.parse(log.recordedOn)?.formatted(date: .abbreviated, time: .shortened) ?? "")")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        
                    } else {
                        FPChevronRowView {
                            viewModel.didTapTicketLog?(log)
                        } children: {
                            VStack(alignment: .leading) {
                                Text(log.news)
                                    .lineLimit(1)
                                Text("\(Date.parse(log.recordedOn)?.formatted(date: .abbreviated, time: .shortened) ?? "")")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                
            } else {
                VStack(alignment: .leading) {
                    Text("XXX XXXXXXX XXXX XX XXXX XXXXXX")
                        .redacted(reason: [.placeholder])
                    Text("Date unknown")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                }
                VStack(alignment: .leading) {
                    Text("XXX XXXXXXX XXXX XX")
                        .redacted(reason: [.placeholder])
                    Text("Date unknown")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                }
            }
        } header: {
            Text("Activity Logs")
        } footer: {
            Text("Logs are the representation of events that happened to a ticket. Every log entries are visible through the print view.")
        }
    }
    
    
    var id = UUID()
    
}



fileprivate struct HandlerListView: Identifiable, View {
    
    
    @Bindable var viewModel: TicketDetailSwiftUIViewModel
    
    
    @State var previewedHandler: FPPerson?
    
    
    var body: some View {
        Section {
            if let ticket = viewModel.ticket {
                let handlers = ticket.handlers.map {
                    var mod = $0.model
                    mod.extras = $0.extrasAsStringMap()
                    return mod
                }
                
                ForEach(handlers, id: \.self) { handler in
                    FPChevronRowView {
                        previewedHandler = handler
                    } children: {
                        VStack(alignment: .leading) {
                            Text(handler.name)
                            Text(handler.title ?? "")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        .multilineTextAlignment(.leading)
                    }
                    .sheet(item: $previewedHandler) { handler in
                        NavigationView {
                            Form {
                                Section("Name") {
                                    Text(handler.name)
                                }
                                Section("Title") {
                                    Text(handler.title ?? "")
                                }
                                Section("Specialties") {
                                    Text(handler.specialtiesName)
                                }
                                ForEach(handler.extras.map({ ($0.key, $0.value) }).map({ Wrapper(key: $0, value: $1) })) { info in
                                    Section(info.key) {
                                        HStack {
                                            Text(info.value)
                                            Spacer()
                                            Button("Copy") {
                                                VUCopyToClipboard(info.value)
                                            }
                                        }
                                    }
                                }
                            }
                            .navigationTitle("Contact information")
                            .navigationBarTitleDisplayMode(.inline)
                        }
                        .presentationDetents([.medium, .large])
                    }
                }
            } else {
                VStack(alignment: .leading) {
                    Text("XXX XXXXXX")
                        .redacted(reason: .placeholder)
                    Text("No title")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.leading)
            }
        } header: {
            Text("Assigned Handlers")
        } footer: {
            Text(LocalizedStringResource("Tap on their name to access their contact information."))
        }
    }
    
    
    var id = UUID()
    
}



// MARK: -- Conditional screens

fileprivate struct TicketRejectionView: View {
    
    
    @Bindable var viewModel: TicketDetailSwiftUIViewModel
    
    
    @State var shouldShowFileImporter: Bool = false
    
    
    @State var rejectionReason: String = .EMPTY
    
    
    @State var supportiveDocuments: [URL] = []
    
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Duplicate tickets", text: $rejectionReason, axis: .vertical)
                        .lineLimit(2...4)
                        .multilineTextAlignment(.leading)
                } header: {
                    Text("Rejection reason • Optional")
                } footer: {
                    Text(
                         """
                         A good reason should address the concerns directly, while also providing an explanation as to why it cannot be resolved through a ticket. 
                         
                         It should clearly state whether the request is inappropriate, irrelevant, or out of scope. [Learn more](https://google.com)
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
                                    supportiveDocuments.append(contentsOf: fileURLs)
                                }
                            case .failure(let error):
                                VULogger.log(tag: .error, error)
                        }
                    }
                    
                    List(supportiveDocuments, id: \.self) { file in 
                        NavigationLink(file.lastPathComponent) { 
                            QuickLookPreview(fileURL: file)
                                .interactiveDismissDisabled()
                        }
                            .swipeActions { 
                                Button("Delete", role: .destructive) {
                                    supportiveDocuments.removeAll { $0 == file }
                                }
                            }
                    }
                } header: {
                    Text("Supportive Documents")
                } footer: {
                    Text("Tap on each of the file’s name to preview them. Swipe leftwards to delete them. [Learn more](https://google.com) about picking a more helpful supportive documents.")
                }
            }
            .toolbar{
                ToolbarItem(placement: .cancellationAction) { 
                    Button("Cancel") {
                        viewModel.shouldShowRejectionAlert = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) { 
                    Button("Reject") {
                        Task {
                            try await viewModel.didRejectTicket?(rejectionReason, supportiveDocuments)
                            viewModel.shouldShowRejectionAlert = false
                        }
                    }
                    .disabled(
                        !(!rejectionReason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        && !supportiveDocuments.isEmpty)
                    )
                }
            }
            .navigationTitle("Rejecting a ticket")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .interactiveDismissDisabled(!rejectionReason.isEmpty)
    }
    
}



#Preview {
    @Previewable var viewModel = TicketDetailSwiftUIViewModel(role: .member)
    NavigationStack {
        TicketDetailSwiftUIView(viewModel: viewModel)
    }
}
