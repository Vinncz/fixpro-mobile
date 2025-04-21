import SwiftUI
import VinUtility



/// The SwiftUI View that is bound to be presented in ``OperationsViewController``.
struct OperationsSwiftUIView: View {
    
    
    /// Two-ways communicator between ``OperationsInteractor`` and self.
    @Bindable var viewModel: OperationsSwiftUIViewModel
    
    @State private var degree: Int = 270
    @State private var spinnerLength = 0.6
    @State private var spinnerVisible: Bool = false
    
    var body: some View {
        VUIndenterView(.one) {
            VStack(spacing: VUViewSize.xxxBig.val) {
                Image("fixpro-logo")
                
                Loader()
                    .opacity(spinnerVisible ? 1 : 0)
                    .frame(height: spinnerVisible ? 45 : 0)
                
                VStack(spacing: VUViewSize.normal.val) {
                    if case let .normal(operationString) = viewModel.state {
                        Text(operationString)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .onAppear {
                                spinnerVisible = true
                            }
                        
                    } else if case let .failure(errorMsg, buttonLabel, actionable) = viewModel.state {
                        Text(errorMsg)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(LocalizedStringKey(buttonLabel)) {
                            actionable()
                        }
                            .buttonStyle(.borderedProminent)
                            .onAppear {
                                spinnerVisible = false
                            }
                        
                    }
                }
            }
        }
    }
    
}



extension OperationsSwiftUIView {
    
    
    @ViewBuilder func Loader () -> some View {
        Circle()
            .trim(from: 0.0,to: spinnerLength)
            .stroke(LinearGradient(colors: [.accentColor, .secondary], 
                                   startPoint: .topLeading, 
                                   endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: 6.0,
                                       lineCap: .round,
                                       lineJoin:.round))
            .animation(.easeIn(duration: 1.5).repeatForever(), value: spinnerLength)
            .frame(width: 45,height: 45)
            .rotationEffect(Angle(degrees: Double(degree)))
            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: spinnerLength)
            .onAppear {
                degree = 270 + 360
                spinnerLength = 0
            }
    }
    
}



#Preview {
    @Previewable var viewModel = OperationsSwiftUIViewModel()
    
    OperationsSwiftUIView(viewModel: viewModel)
        .onAppear {
            Task {
                try await Task.sleep(nanoseconds: 2_000_000_000)
                viewModel.state = .normal("Purging")
                try await Task.sleep(nanoseconds: 2_000_000_000)
                viewModel.state = .normal("Dying")
                try await Task.sleep(nanoseconds: 2_000_000_000)
                viewModel.state = .failure("No internet", "Retry") {
                    print("refreshing")
                }
            }
        }
}
