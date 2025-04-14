import SwiftUI
import VinUtility

struct BootstrapSwiftUIView: View {
    
    @Bindable var viewModel: BootstrapSwiftUIViewModel
    @State var disclosureIsExpanded = true
    @State var isPairingReceiptValid = true
    @State var isShowingAbandonApplicationAlert = false
    
    fileprivate let features: [Feature] = [
        .thirdPartyIntegration
        ,.statisticsAndTrends
        ,.keepingYouInTouch
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                if let pairingReceipt = viewModel.applicationReceipt {
                    Section {
                        ApplicationSummaryView(pairingReceipt: pairingReceipt)
                    } header: {
                        Text("Your Active Application")
                    } footer: {
                        ApplicationSystemExplanation()
                    }
                }
                Section("Features") {
                    FeatureView()
                }
            }
            .navigationTitle("FixPro")
            .refreshable {
                viewModel.refreshApplicationStatus?()
                refreshLocalPairingState()
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) { 
                    PairingButton()
                }
            }
        }
        .onAppear {
            refreshLocalPairingState()
        }
        .alert(isPresented: $isShowingAbandonApplicationAlert) {
            Alert(
                title: Text("You wish to abandon this application?"),
                message: Text(""),
                primaryButton: .destructive(Text("Abandon it")) {
                    viewModel.cancelApplicationAndRemoveReceipt?()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
}



extension BootstrapSwiftUIView {
    
    func refreshLocalPairingState () {
        if let pairingReceipt = viewModel.applicationReceipt {
            isPairingReceiptValid = isDate(.now, before: pairingReceipt.offerExpiryDate)
        }
    }
    
}



extension BootstrapSwiftUIView {
    
    @ViewBuilder func ApplicationSummaryView (pairingReceipt: ApplicationReceipt) -> some View {
        DisclosureGroup(isExpanded: $disclosureIsExpanded) {
            HStack {
                Text("Applied on")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(pairingReceipt.appliedOnDate.formatted(date: .abbreviated, time: .shortened))
            }
            HStack {
                Text("Expires on")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(pairingReceipt.offerExpiryDate.formatted(date: .abbreviated, time: .shortened))
            }
            HStack {
                switch viewModel.applicationState {
                    case .undecided:
                        Text("*Awaiting approval*..")
                        
                    case .approvedAndReadyForTransition:
                        Text("Approved")
                        Spacer()
                        Button("Join now") {
                            viewModel.queOperationalFlow?()
                        }
                        
                    case .rejected:
                        Text("Rejected")
                        Spacer()
                        Button("Abandon application", role: .destructive) {
                            isShowingAbandonApplicationAlert = true
                        }
                        
                    case .expired:
                        Text("Rejected")
                        Spacer()
                        Button("Abandon application", role: .destructive) {
                            isShowingAbandonApplicationAlert = true
                        }
                }
            }
        } label: {
            Label {
                Text(pairingReceipt.areaName)
                    .onLongPressGesture {
                        viewModel.cancelApplicationAndRemoveReceipt?()
                    }
            } icon: {
                Image(systemName: "building.2.fill")
            }   
        }
    }
    
    @ViewBuilder func ApplicationSystemExplanation () -> some View {
        VStack(alignment: .leading, spacing: VUViewSize.small.val) {
            Text("For every requests that you sent, the Area will be given some amount of time to approve them.")
            Text("Within this span, you'll be unable to join to another Area, and that request of yours can either go rejected or approved.")
            Text("Swipe down from above to refresh your status.")
        }
            .multilineTextAlignment(.leading)
    }
    
    @ViewBuilder func FeatureView () -> some View {
        ForEach(features) { feature in
            Label { 
                VStack (alignment: .leading, spacing: VUViewSize.xSmall.val) {
                    Text(feature.title)
                        .font(.headline)
                        .bold()
                    Text(feature.shortSellout)
                        .foregroundStyle(.secondary)
                }
            } icon: { 
                Image(systemName: feature.image)
            }
        }
        .tint(.accentColor)
    }
    
    @ViewBuilder func PairingButton () -> some View {
        Button {
            viewModel.quePairingFlow?()
        } label: {
            Text("Join an Area")
                .padding(.vertical, VUViewSize.small.val)
                .padding(.horizontal, VUViewSize.big.val * 6)
        }
            .padding(.top, VUViewSize.small.val)
            .overlay(Rectangle().fill(.clear))
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.applicationReceipt != nil)
    }
    
}



#Preview {
    @Previewable var viewModel = BootstrapSwiftUIViewModel()
    BootstrapSwiftUIView(viewModel: viewModel)
}



fileprivate struct Feature: Identifiable {
    
    var id = UUID()
    var title: String
    var shortSellout: String
    var image: String
    
    static let thirdPartyIntegration: Self = .init(
        title: "Tools that you love (and use)", 
        shortSellout: "Integrate FixPro with your Google Calendar, WhatsApp and more.", 
        image: "square.2.layers.3d.fill"
    )
    
    static let statisticsAndTrends: Self = .init(
        title: "Reporting and trends", 
        shortSellout: "Turn your past tickets into actionable insights with Fixpro.", 
        image: "chart.bar.xaxis"
    )
    
    static let keepingYouInTouch: Self = .init(
        title: "Stay in the loop", 
        shortSellout: "Be informed about happenings that involves you via push notifications.", 
        image: "bell.fill"
    )

}

fileprivate func isDate(_ lhs: Date, before rhs: Date, calledFromLine line: Int = #line) -> Bool {
    lhs < rhs
}
