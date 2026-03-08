//Created by Theron

import SwiftUI
// SwiftUI is used to build the user interface.

import MapKit
// MapKit provides Apple’s map system, including maps,
// annotations, overlays, and geographic regions.


// This view displays a map that visualizes a circular radius
// around a location (used here to show a geofence area).
struct MapRadiusView: View {
    
    // The monitor object contains the center coordinate
    // and radius we want to display on the map.
    var monitor: LocationMonitor
    
    
    // @State stores the current camera position of the map.
    // The map will update automatically when this value changes.
    @State private var position: MapCameraPosition = .automatic
    
    
    // Defines what the UI should look like.
    var body: some View {
        
        // Map view provided by MapKit.
        // The position binding allows us to control
        // what part of the map is visible.
        Map(position: $position) {
            
            // Draws a circular overlay on the map.
            // This represents the monitored geofence area.
            MapCircle(center: monitor.center, radius: monitor.radius)
            
                // Light blue fill color for the circle.
                .foregroundStyle(.blue.opacity(0.2))
                
                // Blue outline around the circle.
                .stroke(.blue, lineWidth: 2)
            
            
            // Displays the user's current location on the map.
            UserAnnotation()
        }
        
        
        // Runs when the view first appears on screen.
        .onAppear {
            
            // Sets the initial map view region so the
            // geofence circle is clearly visible.
            position = .region(
                MKCoordinateRegion(
                    center: monitor.center,
                    
                    // The visible map area is about 3× the radius
                    // so the circle comfortably fits on screen.
                    latitudinalMeters: monitor.radius * 3,
                    longitudinalMeters: monitor.radius * 3
                )
            )
        }
    }
}
