import SwiftUI
import VinUtility



struct FPIssueTicketResponseLevelLabel: View {
    
    
    var responseLevel: FPIssueTicketResponseLevel
    
    
    var body: some View {
        HStack {
            switch responseLevel {
                case .urgentEmergency:
                    Image(systemName: "person.crop.circle.badge.exclamationmark.fill")
                        .getContrastText(backgroundColor: responseLevel.color)
                    Text(responseLevel.shorthandRepresentation)
                        .getContrastText(backgroundColor: responseLevel.color)
                        .font(.footnote)
                        .lineLimit(1)
                        .truncationMode(.tail)
                case .urgent:
                    Image(systemName: "light.beacon.max.fill")
                        .getContrastText(backgroundColor: responseLevel.color)
                    Text(responseLevel.shorthandRepresentation)
                        .getContrastText(backgroundColor: responseLevel.color)
                        .font(.footnote)
                        .lineLimit(1)
                        .truncationMode(.tail)
                default:
                    EmptyView()
            }
        }
        .padding(.horizontal, VUViewSize.small.val)
        .padding(.vertical, VUViewSize.xSmall.val)
        .background(responseLevel.color)
        .clipShape(RoundedRectangle(cornerRadius: 99))
    }
    
}
