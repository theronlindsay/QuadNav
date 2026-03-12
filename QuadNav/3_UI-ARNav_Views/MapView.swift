//Created by Theron

import SwiftUI
// SwiftUI is used to build the interface of the app.

import MapKit
// MapKit provides Apple's map system for displaying maps,
// locations, and map annotations.


// This view displays the main campus map and building markers.
struct MapView: View {
    
    // @Binding allows this view to both read and update
    // the selected building from its parent view.
    @Binding var selectedBuilding: Building?
    
    
    // The user's current GPS location (optional because
    // the location may not be known immediately).
    let userLocation: CLLocation?
    
    
    // A list of buildings that will appear as markers on the map.
    let buildings: [Building]
    
    
    // MARK: - Recenter Trigger
    // When this value changes, the map recenters on the user.
    let recenterTrigger: UUID
    
    
    // Controls the map camera (what part of the map is visible).
    // This starts centered on the user's location if available.
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    
    // Defines the layout of the map view.
    var body: some View {
        
        // The main Apple Map view.
        // The position binding allows the map camera to change dynamically.
        Map(position: $position) {
            
            
            // Shows the user's location marker on the map.
            UserAnnotation()
            
            
            // Loop through each building in the list
            // and place a marker on the map.
            ForEach(buildings) { building in
                
                // Creates a custom annotation (marker) at the building's location.
                Annotation(building.name, coordinate: building.coordinate) {
                    
                    // Map pin icon from Apple's SF Symbols.
                    Image(systemName: "mappin.circle.fill")
                        .font(.title)
                        
                        // If this building is selected, show it in blue.
                        // Otherwise show it in red.
                        .foregroundStyle(
                            selectedBuilding == building ? .blue : .red
                        )
                        
                        // When the user taps the marker,
                        // update the selected building.
                        .onTapGesture {
                            selectedBuilding = building
                        }
                }
            }
        }
        
        
        // MARK: - Recenter Logic
        
        .onChange(of: recenterTrigger) {
            position = .userLocation(fallback: .automatic)
        }
    }
}

