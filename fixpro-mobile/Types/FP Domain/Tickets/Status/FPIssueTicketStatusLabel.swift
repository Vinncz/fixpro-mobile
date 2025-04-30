import SwiftUI
import VinUtility



struct FPIssueTicketStatusLabel: View {
    
    
    var status: FPIssueTicketStatus
    
    
    var body: some View {
        Text(status.shorthandRepresentation)
            .getContrastText(backgroundColor: status.color)
            .font(.footnote)
            .lineLimit(1)
            .truncationMode(.tail)
            .frame(maxWidth: 64)
            .padding(.horizontal, VUViewSize.small.val)
            .padding(.vertical, VUViewSize.xSmall.val)
            .background(status.color)
            .clipShape(RoundedRectangle(cornerRadius: 99))
    }
    
}



#Preview {
    VStack {
        FPIssueTicketStatusLabel(status: .open)
        FPIssueTicketStatusLabel(status: .inAssessment)
        FPIssueTicketStatusLabel(status: .onProgress)
        FPIssueTicketStatusLabel(status: .workEvaluation)
        FPIssueTicketStatusLabel(status: .closed)
        FPIssueTicketStatusLabel(status: .cancelled)
        FPIssueTicketStatusLabel(status: .rejected)
    }
}


extension View {
    func getContrastText(backgroundColor: Color) -> some View {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)
        UIColor(backgroundColor).getRed(&r, green: &g, blue: &b, alpha: &a)
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        return  luminance < 0.6 ? self.foregroundColor(.white) : self.foregroundColor(.black)
    }
}
