import SwiftUI

struct CodeScanView: View {
    
    @Environment(\.isPresented) var isPresented
    @Bindable var viewModel: CodeScanViewModel
    
    var body: some View {
        ScrollView {
            ScannerView ([.captureMode: .wrap(ScannerView.CaptureMode.continuous), .debounce: .wrap(TimeInterval(integerLiteral: 3))], error: $viewModel.scannerError) { result in
                viewModel.didScan?(result)
            }
                .background(.primary)
                .frame(height: 1.25 * ViewSize.cCompact.val)
                .padding(.bottom, ViewSize.xSmall.val)
            
            Indenter(.one) {
                if !viewModel.scannerError.isEmpty {
                    HStack (alignment: .firstTextBaseline) {
                        Image(systemName: "exclamationmark.triangle")
                        Text(viewModel.scannerError)
                        Spacer()
                    }
                    .foregroundStyle(.red)
                    .padding()
                    .background(.red.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            
            Indenter(.one) {
                VStack(spacing: ViewSize.normal.val) {
                    Text("You'll be automatically redirected once a fitting code has been found.")
                }
                .foregroundStyle(.secondary)
            }
        }
    }
}
