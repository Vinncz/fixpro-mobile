import SwiftUI
import VinUtility



/// The SwiftUI View that is bound to be presented in ``AreaJoinningCodeScanningViewController``.
struct AreaJoinningCodeScanningSwiftUIView: View {
    
    
    /// Two-ways communicator between ``AreaJoinningCodeScanningInteractor`` and self.
    @Bindable var viewModel: AreaJoinningCodeScanningSwiftUIViewModel
    
    
    @State var manualInputHostingAddress: String = ""
    
    
    @State var manualInputReferralTrackingIdentifier: String = ""
    
    
    var body: some View {
        ScrollView {
            VUScannerView ([.captureMode: .wrap(VUScannerView.CaptureMode.continuous), .debounce: .wrap(TimeInterval(integerLiteral: 3))], error: $viewModel.scannerError, isScanning: $viewModel.isScanning) { result in
                viewModel.didScan?(result)
            }
                .background(.primary)
                .frame(height: 1.25 * VUViewSize.cCompact.val)
                .overlay {
                    GeometryReader { geo in 
                        HStack {
                            Spacer()
                            VStack {
                                Spacer()
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.secondary.opacity(0.75), style: StrokeStyle(
                                        lineWidth: 3, 
                                        lineCap: .round, 
                                        lineJoin: .round, 
                                        dash: [12, 8], 
                                    ))
                                    .frame(width: geo.size.width * 0.65, height: geo.size.width * 0.65)
                                    .shadow(color: .primary, radius: 12)
                                Spacer()
                            }
                            Spacer()
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.vertical, VUViewSize.small.val)
                .padding(.horizontal, VUViewSize.xSmall.val)
            
            VUIndenterView(.one) {
                if !viewModel.scannerError.isEmpty {
                    HStack(alignment: .firstTextBaseline, spacing: VUViewSize.small.val) {
                        Image(systemName: "exclamationmark.triangle")
                            .bold()
                        Text(LocalizedStringKey(viewModel.scannerError))
                        Spacer()
                    }
                    .foregroundStyle(.red)
                    .padding()
                    .background(.red.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                } else {
                    HStack(alignment: .firstTextBaseline, spacing: VUViewSize.small.val) {
                        Image(systemName: "arrowshape.turn.up.forward.fill")
                        Text("You'll be automatically redirected once a fitting code has been found.")
                        Spacer()
                    }
                    .foregroundStyle(.secondary)
                    .padding()
                    .background(.secondary.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.isInputingManually) {
            NavigationView {
                Form {
                    Section("Hosting Address") {
                        TextField("https://...", text: $manualInputHostingAddress)
                    }
                    Section("Referral Tracking Indentifier") {
                        TextField("6 digit code", text: $manualInputReferralTrackingIdentifier)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) { 
                        Button("Done") {
                            viewModel.didScan?(
                                """
                                {"endpoint": "\(manualInputHostingAddress)", "referralTrackingIdentifier": "\(manualInputReferralTrackingIdentifier)"}
                                """
                            )
                            viewModel.isInputingManually = false
                            viewModel.isScanning = true
                        }
                    }
                    ToolbarItem(placement: .cancellationAction) { 
                        Button("Cancel") {
                            viewModel.isInputingManually = false
                            viewModel.isScanning = true
                        }
                    }
                }
            }
                .onAppear {
                    viewModel.isScanning = false
                }
        }
        .onDisappear {
            viewModel.isScanning = false
            viewModel.scannerError = .EMPTY
        }
        .onAppear {
            viewModel.isScanning = true
        }
    }
    
}



#Preview {
    @Previewable var viewModel = AreaJoinningCodeScanningSwiftUIViewModel()
    AreaJoinningCodeScanningSwiftUIView(viewModel: viewModel)
}
