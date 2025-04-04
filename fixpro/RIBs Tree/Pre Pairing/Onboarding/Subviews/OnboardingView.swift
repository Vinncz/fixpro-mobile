import SwiftUI
import OpenAPIRuntime
import OpenAPIURLSession

struct OnboardingView: View {
    
    let onButtonClick: () -> Void
    let onInfoClick: () -> Void
    
    private let client: Client
    
    init(onButtonClick: @escaping () -> Void, onInfoClick: @escaping () -> Void) {
        self.onButtonClick = onButtonClick
        self.onInfoClick = onInfoClick
        self.client = Client(
            serverURL: try! Servers.PairedAreaAddress.url(),
            transport: URLSessionTransport()
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    FeatureAdvertView()
                }
                .padding(.top, ViewSize.normal.val)
                Indenter(.one) {
                    VStack {
                        Button {
                            onButtonClick()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Join an Area")
                                Spacer()
                            }
                            .padding(ViewSize.small.val)
                        }
                        .buttonStyle(.borderedProminent)
                        Text("By joinning, you agree to our [Terms of Service](https://www.notion.so/FixPro-1608e7ee3d0c801a8c3cf114d0a7eef1?pvs=4) and [Privacy Policy](https://www.notion.so/FixPro-1608e7ee3d0c801a8c3cf114d0a7eef1?pvs=4).")
                            .multilineTextAlignment(.center)
                            .font(.caption)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { 
                    Button {
                        onInfoClick()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
            }
            .navigationTitle("FixPro")
        }
    }
    
}

#Preview {
    OnboardingView(){}onInfoClick:{}
}
