import SwiftUI
import MapKit

struct MapRadiusView: View {
    var monitor: LocationMonitor
    @State private var position: MapCameraPosition = .automatic
    
    var body: some View {
        Map(position: $position) {
            MapCircle(center: monitor.center, radius: monitor.radius)
                .foregroundStyle(.blue.opacity(0.2))
                .stroke(.blue, lineWidth: 2)
            UserAnnotation()
        }
        .onAppear {
            position = .region(MKCoordinateRegion(
                center: monitor.center,
                latitudinalMeters: monitor.radius * 3,
                longitudinalMeters: monitor.radius * 3
            ))
        }
    }
}
