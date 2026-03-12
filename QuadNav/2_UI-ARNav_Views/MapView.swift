//
// MapView.swift
// Created by Theron, Brandon Williams & Amber Taggart
//

import SwiftUI
import MapKit

// MARK: - Campus Map View
// Displays campus map, user location, and building markers
struct MapView: View {
    
    // MARK: - Bindings & Inputs
    
    /// Selected building from parent view
    @Binding var selectedBuilding: Building?
    
    /// User's current location
    let userLocation: CLLocation?
    
    /// Buildings to display as map markers
    let buildings: [Building]
    
    /// Trigger to recenter map on user
    let recenterTrigger: UUID
    
    
    // MARK: - State
    
    /// Controls the map camera position
    @State private var position: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    
    
    // MARK: - Body
    
    var body: some View {
        Map(position: $position) {
            
            // User location marker
            UserAnnotation()
            
            // Building markers
            ForEach(buildings) { building in
                Annotation(building.name, coordinate: building.coordinate) {
                    
                    Image(systemName: "mappin.circle.fill")
                        .font(.title)
                        .foregroundStyle(
                            selectedBuilding == building ? .blue : .red
                        )
                        .onTapGesture {
                            selectedBuilding = building
                        }
                }
            }
        }
        .mapControls {
            MapCompass()
            MapUserLocationButton() // Allows re-enabling follow mode manually
        }
        
        // MARK: - Recenter Logic
        
        .onChange(of: recenterTrigger) {
            position = .userLocation(fallback: .automatic)
        }
    }
}
