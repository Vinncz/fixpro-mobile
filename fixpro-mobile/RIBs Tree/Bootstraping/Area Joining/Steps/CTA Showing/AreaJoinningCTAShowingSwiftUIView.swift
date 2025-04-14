import SwiftUI
import VinUtility



/// The SwiftUI View that is bound to be presented in ``AreaJoinningCTAShowingViewController``.
struct AreaJoinningCTAShowingSwiftUIView: View {
    
    
    /// Two-ways communicator between ``AreaJoinningCTAShowingInteractor`` and self.
    @Bindable var viewModel: AreaJoinningCTAShowingSwiftUIViewModel
    
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: VUViewSize.big.val) {
                    HStack {
                        Spacer()
                        Image(systemName: "person.fill.checkmark")
                            .font(.system(size: 56))
                        Spacer()
                    }
                        .frame(height: geo.size.height / 2)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    VUIndenterView(.one) {
                        VStack(alignment: .leading, spacing: VUViewSize.normal.val) {
                            Text("Your application will now go on review.")
                                .font(.title)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                                .bold()
                            Text("Once approved, you can start using FixPro in your area. This step may span up to 2 days, so check back regularly.")
                                .foregroundStyle(.secondary)
                            Text("In the meantime, check out the [FixPro documentation](https://www.notion.so/FixPro-1608e7ee3d0c801a8c3cf114d0a7eef1?pvs=4) where you can find guides on doing things.")
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
        }
        .safeAreaPadding(.all)
    }
    
}



#Preview {
    @Previewable var viewModel = AreaJoinningCTAShowingSwiftUIViewModel()
    AreaJoinningCTAShowingSwiftUIView(viewModel: viewModel)
}
