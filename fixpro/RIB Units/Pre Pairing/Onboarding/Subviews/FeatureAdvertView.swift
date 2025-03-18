import SwiftUI

struct FeatureAdvertView: View {
    
    fileprivate let features: [Feature] = [
        .thirdPartyIntegration
        ,.statisticsAndTrends
        ,.keepingYouInTouch
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: ViewSize.big.val) {
            ForEach (features) { feature in
                FeatureRow(feature: feature)
            }
        }
    }
    
}

fileprivate struct FeatureRow: View {
    let feature: Feature
    var body: some View {
        HStack (alignment: .top, spacing: ViewSize.normal.val) {
            Image(systemName: feature.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(ViewSize.small.val)
                .frame(width: 2 * ViewSize.xBig.val, height: 2 * ViewSize.xBig.val)
            VStack (alignment: .leading, spacing: ViewSize.xSmall.val) {
                Text(feature.title)
                    .font(.title3)
                    .bold()
                Text(feature.shortSellout)
                    .opacity(0.6)
            }
            Spacer()
        }
        .padding(.horizontal, ViewSize.medium.val)
    }
}

fileprivate struct Feature: Identifiable {
    
    var id = UUID()
    var title: String
    var shortSellout: String
    var image: String
    
    static let thirdPartyIntegration: Self = .init(
        title: "Tools that you love", 
        shortSellout: "Pair FixPro with your Google Calendar, WhatsApp and more.", 
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
        image: "bell.square.fill"
    )

}

#Preview {
    FeatureAdvertView()
}
