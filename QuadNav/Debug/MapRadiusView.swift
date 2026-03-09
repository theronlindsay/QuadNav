//Created by Theron

import SwiftUI
// SwiftUI is used to build the user interface.

import MapKit
// MapKit provides Apple’s map system, including maps,
// annotations, overlays, and geographic regions.


// This view displays a map that visualizes a circular radius
// around a location (used here to show a geofence area).
struct MapRadiusView: View {
    
    @Bindable var monitor: LocationMonitor
    
    @State private var position: MapCameraPosition = .automatic
    
    var body: some View {
        
        Map(position: $position) {
            
            MapCircle(center: monitor.center, radius: monitor.radius)
                .foregroundStyle(.blue.opacity(0.2))
                .stroke(.blue, lineWidth: 2)
            
            UserAnnotation()
        }
        
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        
        .onAppear {
            position = .region(
                MKCoordinateRegion(
                    center: monitor.center,
                    latitudinalMeters: monitor.radius * 3,
                    longitudinalMeters: monitor.radius * 3
                )
            )
        }
    }
}
