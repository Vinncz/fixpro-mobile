import SwiftUI



struct FPChevronRowView<Children: View>: View {
    
    
    var tapAction: () -> Void
    @ViewBuilder var children: Children
    
    
    var body: some View {
        DisclosureGroup(isExpanded: Binding(
            get: { 
                false
            }, 
            set: { _ in
                tapAction()
            }
        )) {} 
        label: {
            children
        }
        .tint(.secondary)
    }
    
}
