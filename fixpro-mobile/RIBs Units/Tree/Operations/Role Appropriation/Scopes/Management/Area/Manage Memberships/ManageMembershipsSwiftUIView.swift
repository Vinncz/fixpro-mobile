import SwiftUI
import VinUtility



fileprivate enum Segments: String, CaseIterable, Hashable, Identifiable {
    case pending = "Pending"
    case members = "Members"
    
    var id: Self { self }
}



/// The SwiftUI View that is bound to be presented in ``ManageMembershipsViewController``.
struct ManageMembershipsSwiftUIView: View {
    
    
    /// Two-ways communicator between ``ManageMembershipsInteractor`` and self.
    @Bindable var viewModel: ManageMembershipsSwiftUIViewModel
    
    
    @State fileprivate var segment: Segments = .pending
    
    
    var body: some View {
        Form {
            Picker("Segment", selection: $segment) {
                ForEach(Segments.allCases) { segment in 
                    Text(segment.rawValue)
                }
            }
                .pickerStyle(.segmented)
                .listRowInsets(.init())
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(Color.clear)
            
            switch segment {
                case .pending:
                    SectionApplicants(viewModel: viewModel)
                case .members:
                    SectionMembers(viewModel: viewModel)
            }
        }
        .refreshable {
            await viewModel.didRefresh?()
        }
    }
    
}



fileprivate struct SectionApplicants: View {
    
    
    @Bindable var viewModel: ManageMembershipsSwiftUIViewModel
    
    
    var body: some View {
        let grouped = timeLoggedSection(fromApplicants: viewModel.applicants)
        if viewModel.applicants.count > 0 {
            ForEach(FPTimeLoggedSection.allCases, id: \.self) { section in 
                if let sectionApplicants = grouped[section], !sectionApplicants.isEmpty {
                    Section(header: Text(section.rawValue)) {
                        ForEach(sectionApplicants) { applicant in 
                            FPChevronRowView { 
                                viewModel.didTapApplicant?(applicant)
                            } children: { 
                                Text("\(applicant.formAnswer.first?.fieldValue ?? "No Name")")
                            }
                        }
                    }
                }
            }
            
        } else {
            Section {
                HStack(alignment: .top) {
                    ContentUnavailableView("No Applicants", 
                                           systemImage: "person.2.slash", 
                                           description: Text("When people apply to join to your area, they'll show up here.\n\nInvite people to join your area by sharing your Area Join Code."))
                }
                .frame(height: 350)
                .padding(.top, VUViewSize.xxxBig.val * 3)
                .listRowInsets(.init())
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(Color.clear)
            }
        }
    }
    
}



fileprivate struct SectionMembers: View {
    
    
    @Bindable var viewModel: ManageMembershipsSwiftUIViewModel
    
    
    var body: some View {
        if viewModel.members.count > 0 {
            ForEach(FPTokenRole.allCases, id: \.self) { role in 
                let membersWithRole = viewModel.members.filter { $0.role == role }
                
                if !membersWithRole.isEmpty {
                    Section(header: Text(role.rawValue + "s")) {
                        ForEach(membersWithRole) { member in 
                            FPChevronRowView { 
                                viewModel.didTapMember?(member)
                            } children: { 
                                VStack(alignment: .leading) {
                                    Text(member.name)
                                        .foregroundColor(.primary)
                                        .font(.body)
                                        .lineLimit(1)
                                    if let title = member.title {
                                        Text(title)
                                            .foregroundColor(.secondary)
                                            .font(.body)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        } else {
            Section {
                HStack(alignment: .top) {
                    ContentUnavailableView("No Members", 
                                           systemImage: "person.2.slash.fill", 
                                           description: Text("Aside from you, there are nobody else.\n\nWhen there are more members, they'll show up here."))
                }
                .frame(height: 350)
                .padding(.top, VUViewSize.xxxBig.val * 3)
                .listRowInsets(.init())
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(Color.clear)
            }
        }
    }
    
}



fileprivate func timeLoggedSection(fromApplicants applicants: [FPEntryApplication]) -> [FPTimeLoggedSection: [FPEntryApplication]] {
    Dictionary(grouping: applicants) { applicant in
        if let submittedOnDate: Date = try? Date(applicant.submittedOn, strategy: .iso8601) {
            return FPTimeLoggedSection.category(for: submittedOnDate)
        } else {
            return FPTimeLoggedSection.category(for: .distantPast)
        }
    }
}



#Preview {
    @Previewable var viewModel = ManageMembershipsSwiftUIViewModel()
    ManageMembershipsSwiftUIView(viewModel: viewModel)
        .onAppear {
//            viewModel.members.append(.init(id: "", name: "Kodok", role: .management, specialties: [.unselected], capabilities: [], memberSince: .EMPTY))
        }
}
