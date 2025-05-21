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
    
    
    @State var mapLocation: FPGPSLocation?
    @State var previewedSupportiveDocument: FPSupportiveDocument?
    @State var previewedHandler: FPPerson?
    
    
    var body: some View {
        Form {
            SummaryView()
            IssueDescriptionView()
            ReportedLocationView()
            SupportiveDocumentsListView()
            LogsListView()
            HandlersListView()
        }
        .scrollDismissesKeyboard(.immediately)
        .refreshable {
            await viewModel.didIntedToRefresh?()
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
            }
            .interactiveDismissDisabled()
            .presentationDetents([.medium, .large])
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
    }
    
}



extension TicketDetailSwiftUIView {
    
    
    @ViewBuilder func SummaryView() -> some View {
        Section {
            HStack {
                Text("Issue type")
                Spacer()
                Text(viewModel.issueTypes.map{ $0.name }.coalesce())
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .redacted(reason: viewModel.issueTypes.isEmpty ? .placeholder : [])
                    .multilineTextAlignment(.trailing)
            }
            HStack {
                Text("Response level")
                Spacer()
                Text(viewModel.responseLevel?.rawValue ?? "response-level-placeholder")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .redacted(reason: viewModel.responseLevel == nil ? .placeholder : [])
            }
            HStack {
                Text("Raised on")
                Spacer()
                Text("\(Date.parse(viewModel.raisedOn ?? "")?.formatted(date: .abbreviated, time: .shortened) ?? "")")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .redacted(reason: viewModel.raisedOn == nil ? .placeholder : [])
            }
            HStack {
                Text("Current status")
                Spacer()
                Text(viewModel.status?.rawValue ?? "status-placeholder")
                    .font(.callout)
                    .foregroundStyle(viewModel.status?.color ?? .secondary)
                    .redacted(reason: viewModel.status == nil ? .placeholder : [])
            }
            
        } header: {
            Text("Summary")
        } footer: {
            Text(LocalizedStringResource("The status above changes each time a log entry gets added. [Learn more](https://google.com) about ticket statuses."))
        }
    }
    
    
    @ViewBuilder func IssueDescriptionView() -> some View {
        Section {
            TextField("Stated issue", text: Binding(get: {viewModel.statedIssue ?? "placeholder-thats-not-really-that-long-but-it-counts"}, set: {_ in}), axis: .vertical)
                .lineLimit(4...12)
                .redacted(reason: viewModel.statedIssue == nil ? .placeholder : [])
            
        } header: {
            Text("Stated Issue")
        } footer: {
            Text("The claim above outlines the problem or concern as described by the person who reported it.")
        }
    }
    
    
    @ViewBuilder func ReportedLocationView() -> some View {
        Section {
            if let location = viewModel.location {
                Text(location.reportedLocation)
                Button {
                    mapLocation = location.gpsCoordinates
                } label: {
                    Label("Open on maps", systemImage: "map")
                }
            } else {
                Text("stated-location-placeholder")
                    .redacted(reason: viewModel.location == nil ? .placeholder : [])
                Button {} 
                label: {
                    Label("Open on maps", systemImage: "map")
                }
            }
            
        } header: {
            Text("Reported Location")
        }
    }
    
    
    @ViewBuilder func SupportiveDocumentsListView() -> some View {
        Section {
            if viewModel.supportiveDocuments.count > 0 {
                ForEach(viewModel.supportiveDocuments, id: \.self) { document in
                    FPChevronRowView {
                        previewedSupportiveDocument = document
                    } children: {
                        Text(document.filename)
                    }
                }
                
            } else {
                Text("supportive-document-name-placeholder")
                    .redacted(reason: viewModel.supportiveDocuments.first == nil ? .placeholder : [])
            }
            
        } header: {
            Text("Supportive Documents")
        }
    }
    
    
    @ViewBuilder func LogsListView() -> some View {
        Section {
            if viewModel.logs.count > 0 {
                ForEach(viewModel.logs, id: \.self) { log in
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
                Text("ticket-logs-placeholder")
                    .redacted(reason: viewModel.logs.first == nil ? .placeholder : [])
            }
        } header: {
            Text("Activity Logs")
        } footer: {
            Text(LocalizedStringResource("Logs are the representation of a activities that happened to a Ticket. Every log entries are included in the report."))
        }
    }
    
    
    @ViewBuilder func HandlersListView() -> some View {
        Section {
            if viewModel.supportiveDocuments.count > 0 {
                ForEach(viewModel.handlers, id: \.self) { handler in
                    FPChevronRowView {
                        previewedHandler = handler
                    } children: {
                        HStack {
                            Text(handler.name)
                            Spacer()
                            Text(handler.title ?? "")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
            } else {
                Text("handler-name-placeholder")
                    .redacted(reason: viewModel.handlers.first == nil ? .placeholder : [])
            }
        } header: {
            Text("Assigned Handlers")
        } footer: {
            Text(LocalizedStringResource("Tap on their name to access their contact information."))
        }
    }
    
}



#Preview {
    @Previewable var viewModel = TicketDetailSwiftUIViewModel(role: .member)
    NavigationStack {
        TicketDetailSwiftUIView(viewModel: viewModel)
    }
}
