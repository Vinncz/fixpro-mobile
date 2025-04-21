import SwiftUI



/// The SwiftUI View that is bound to be presented in ``WorkCalendarViewController``.
struct WorkCalendarSwiftUIView: View {
    
    
    /// Two-ways communicator between ``WorkCalendarInteractor`` and self.
    @Bindable var viewModel: WorkCalendarSwiftUIViewModel
    
    
    var body: some View {
        Text("Hello from WorkCalendarSwiftUIView")
    }
    
}



#Preview {
    @Previewable var viewModel = WorkCalendarSwiftUIViewModel()
    WorkCalendarSwiftUIView(viewModel: viewModel)
}
