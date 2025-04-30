import SwiftUI
import MapKit



struct LocationMapView: View {
    
    
    let label: String
    
    
    let coordinate: CLLocationCoordinate2D
    
    
    @State private var region: MKCoordinateRegion
    
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, label: String) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.coordinate = coordinate
        self.label = label
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }
    
    
    var body: some View {
        Map(bounds: .init(minimumDistance: 250, maximumDistance: 10000)) {
            Marker("", coordinate: coordinate)
                .tint(.blue)
        }
        .mapControlVisibility(.visible)
    }
    
}

private struct IdentifiableCoordinate: Identifiable {
    
    
    let id = UUID()
    
    
    let coordinate: CLLocationCoordinate2D
    
}
