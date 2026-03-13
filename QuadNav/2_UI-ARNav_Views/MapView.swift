//
// MapView.swift
// Created by Theron, Brandon Williams & Amber
//

import SwiftUI
import MapKit
// MapKit provides Apple’s map system, including map tiles, user location, annotations, and region control.

// MARK: - Campus Map View
// This view displays a map of the campus, with:
// 1. The user’s location
// 2. Campus building markers
// 3. Logic to recenter the map when the user moves or presses a button
struct MapView: View {
    
    // MARK: - Properties
    
    // Binding allows this view to read and update the selected building
    @Binding var selectedBuilding: Building?
    
    // Optional: The user's current GPS location
    let userLocation: CLLocation?
    
    // List of buildings to show on the map as markers
    let buildings: [Building]
    
    // Trigger to recenter the map when this value changes
    let recenterTrigger: UUID
    
    // State: controls the visible portion of the map
    @State private var position: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    
    // MARK: - Body
    var body: some View {
        
        // The main Map view
        // $position: binding to map camera position; changes here move the map
        Map(position: $position) {
            
            // MARK: - User Location Annotation
            // Displays a blue dot at the user's current location
            UserAnnotation()
            
            // MARK: - Campus Building Markers
            // Loop over the buildings array and add a marker for each one
            ForEach(buildings) { building in
                
                // Annotation shows a custom icon and allows tap interactions
                Annotation(building.name, coordinate: building.coordinate) {
                    
                    // Use a map pin icon (SF Symbol)
                    Image(systemName: "mappin.circle.fill")
                        .font(.title)
                        // Show selected building in blue, others in red
                        .foregroundStyle(selectedBuilding == building ? .blue : .red)
                        // When tapped, update the selected building in parent view
                        .onTapGesture {
                            selectedBuilding = building
                        }
                }
            }
        }
        
        // MARK: - Map Controls
        // Adds UI elements like compass and user location button on the map
        .mapControls {
            MapCompass()          // Shows the compass icon
            MapUserLocationButton() // Button to recenter map on user
        }
        
        // MARK: - Recenter Logic
        // Whenever recenterTrigger changes, reset map camera to follow user
        .onChange(of: recenterTrigger) { _ in
            position = .userLocation(fallback: .automatic)
        }
    }
}
