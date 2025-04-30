import SwiftUI



struct FPEmptyTicketRowView: View {
    
    
    var systemImage: String
    
    
    var message: LocalizedStringResource
    
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: systemImage)
                .foregroundColor(.secondary)
            Text(message)
                .foregroundColor(.primary)
        }
    }
    
}
