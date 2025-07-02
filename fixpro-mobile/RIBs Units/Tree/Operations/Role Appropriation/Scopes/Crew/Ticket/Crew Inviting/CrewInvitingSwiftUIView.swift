import SwiftUI
import VinUtility



/// The SwiftUI View that is bound to be presented in ``CrewInvitingViewController``.
struct CrewInvitingSwiftUIView: View {
    
    
    /// Two-ways communicator between ``CrewInvitingInteractor`` and self.
    @Bindable var viewModel: CrewInvitingSwiftUIViewModel
    
    
    @State var shouldShowFileImporter: Bool = false
    
    
    var body: some View {
        NavigationView {
            if viewModel.ticket.issueTypes.isEmpty {
                VStack {
                    Spacer()
                    ContentUnavailableView(
                        "Unable to Invite", 
                        systemImage: "person.line.dotted.person", 
                        description: Text("Ticket that does not have any issue type cannot be delegated.")
                    )
                    Spacer()
                }
                .background(Color(.systemGroupedBackground))
            } else {
                Form {
                    ForEach ($viewModel.crewInvitingDetails.indices, id: \.self) { index in 
                        IssueTypeSpecificInvitingDetailView(invitingDetails: $viewModel.crewInvitingDetails[index])
                        Divider()
                            .listRowInsets(.init())
                            .listRowBackground(Color.clear)
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
                    
                    Spacer()
                        .frame(height: VUViewSize.xxxBig.val * 2)
                        .listRowBackground(Color.clear)
                }
                .listRowSpacing(0)
                .environment(\.defaultMinListRowHeight, 0)
                .environment(viewModel)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { 
                        Button("Cancel") {
                            viewModel.didIntendToCancel?()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) { 
                        Button("Invite") {
                            Task {
                                try await viewModel.didIntendToInvite?()
                            }
                        }
                        .disabled(
                            !viewModel.crewInvitingDetails.allSatisfy({ detail in
                                !detail.personnel.isEmpty
                                && !detail.workDirective.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            })
                        )
                    }
                }
                .navigationTitle("Inviting colleagues")
                .navigationBarTitleDisplayMode(.inline)
                .scrollDismissesKeyboard(.immediately)
            }
        }
    }
    
}



fileprivate struct IssueTypeSpecificInvitingDetailView: View {
    
    
    @Environment(CrewInvitingSwiftUIViewModel.self) var viewModel: CrewInvitingSwiftUIViewModel
    
    
    @Binding var invitingDetails: CrewInvitingDetail
    
    
    var body: some View {
        Section {
            TextField("Try \"Replace the lightbulb\"", text: $invitingDetails.workDirective, axis: .vertical)
                .lineLimit(2...4)
        } header: {
            VStack(alignment: .leading) {
                Text(invitingDetails.issueType.name)
                    .font(.headline)
                    .headerProminence(.increased)
                Text("WORK DIRECTIVE")
                    .foregroundStyle(.secondary)
            }
            .foregroundStyle(.primary)
        } footer: {
            Text("A good directive explains *what* need to be done and the preferred method to accomplish it. [Learn more](https://google.com).")
        }
        
        Section {
            let matchingPersonnel: [FPPerson] = viewModel.availablePersonnel.filter { individualPersonnel in 
                individualPersonnel.specialties.contains { $0.id == invitingDetails.issueType.id }
            }
            ForEach(matchingPersonnel, id: \.self) { individualPersonnel in 
                let shouldShowChcekmark: Bool = viewModel.ticket.handlers.map({ $0.model }).map({ $0.id }).contains(individualPersonnel.id)
                
                MultiSelectPickerRow(isSelected: shouldShowChcekmark) {
                    VStack(alignment: .leading) {
                        Text(individualPersonnel.name)
                        if let title = individualPersonnel.title {
                            Text(title)
                                .foregroundStyle(.secondary)
                                .font(.callout)
                        }
                    }
                } callback: { isChecked in 
                    if invitingDetails.personnel.contains(individualPersonnel) {
                        invitingDetails.personnel.removeAll { $0.id == individualPersonnel.id }
                        return false
                    } else {
                        invitingDetails.personnel.append(individualPersonnel)
                        return true
                    }
                }
            }
            if matchingPersonnel.count < 1 {
                ContentUnavailableView(
                    "No Suitable Personnel", 
                    systemImage: "person.fill.xmark", 
                    description: Text("No crew in your area has the matching specialties with this ticket's requirements.")
                )
                .listRowInsets(.init())
                .padding(.top, VUViewSize.xBig.val)
                .scaleEffect(0.85)
            }
        } header: {
            Text("Available personnel")
        }
    }
    
}



fileprivate struct MultiSelectPickerRow<Children: View>: Identifiable, View {
    
    
    var id = UUID()
    
    
    @State var isSelected: Bool = false
    
    
    @ViewBuilder var children: Children
    
    
    var callback: (Bool)->Bool
    
    
    var body: some View {
        HStack {
            children
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundStyle(.blue)
            } else {
                EmptyView()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isSelected = callback(isSelected)
        }
    }
    
}



#Preview {
    @Previewable var viewModel = CrewInvitingSwiftUIViewModel(ticket: .init(
        id: "", 
        issueTypes: [
            .init(id: "IT1", name: "Engineering", serviceLevelAgreementDurationHour: "72"),
            .init(id: "IT2", name: "Housekeeping", serviceLevelAgreementDurationHour: "48")
        ], 
        responseLevel: .normal, 
        raisedOn: "\(Date.now.formatted())", 
        status: .onProgress, 
        statedIssue: "Lorem ipsum", 
        location: .init(
            reportedLocation: "Lift entrance, 5th floor", 
            gpsCoordinates: .init(latitude: 0, longitude: 0)
        ), 
        supportiveDocuments: [
            .init(id: "SD1", filename: "Preview.png", mimetype: "image/png", filesize: 2_000_000, hostedOn: URL(string: "https://picsum.photos/1200/1200")!)
        ], 
        issuer: VUExtrasPreservingDecodable<FPPerson>(from: .init(
            id: "P1", 
            name: "Andrew Benjamin", 
            role: .member, 
            specialties: [], 
            capabilities: [], 
            memberSince: "\(Date.now.ISO8601Format())"
        )), 
        logs: [
            .init(
                id: "L1", 
                owningTicketId: "T1", 
                type: .activity, 
                issuer: .init(
                    id: "P1", 
                    name: "Andrew Benjamin", 
                    role: .member, 
                    specialties: [], 
                    capabilities: [], 
                    memberSince: "\(Date.now.ISO8601Format())"
                ), 
                recordedOn: "\(Date.now.ISO8601Format())", 
                news: "Ticket was opened.", 
                attachments: [], 
                actionable: .init(
                    genus: .SEGUE, 
                    species: .TICKET_LOG, 
                    destination: "L1"
                )
            )
        ], 
        handlers: []
    ), authContext: .init(role: .crew, capabilities: [], specialties: []))
    CrewInvitingSwiftUIView(viewModel: viewModel)
        .onAppear {
            viewModel.availablePersonnel = [
                .init(
                    id: "P16", 
                    name: "Romeo Bravo", 
                    role: .member, 
                    title: "Head Engineer",
                    specialties: [
                        .init(id: "IT1", name: "Engineering", serviceLevelAgreementDurationHour: "72"),
                    ], 
                    capabilities: [], 
                    memberSince: "\(Date.now.ISO8601Format())"
                ),
                .init(
                    id: "P17", 
                    name: "Epsilon Banshee", 
                    role: .member, 
                    title: "Handyman",
                    specialties: [
                        .init(id: "IT2", name: "Housekeeping", serviceLevelAgreementDurationHour: "48"),
                    ], 
                    capabilities: [], 
                    memberSince: "\(Date.now.ISO8601Format())"
                ),
                .init(
                    id: "P18", 
                    name: "Epsilon Banshee", 
                    role: .member, 
                    title: "Janitor",
                    specialties: [
                        .init(id: "IT1", name: "Engineering", serviceLevelAgreementDurationHour: "72"),
                    ], 
                    capabilities: [], 
                    memberSince: "\(Date.now.ISO8601Format())"
                )
            ]
        }
}
