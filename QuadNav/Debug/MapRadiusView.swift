//
// MapRadiusView.swift
// Created by Theron
//

import SwiftUI
import MapKit
// SwiftUI: for building user interface declaratively
// MapKit: to display maps, annotations, overlays, and geographic regions

// MARK: - MapRadiusView
// Displays a map showing a circular radius (geofence) around a location.
// Useful for visualizing the Quad area and user location for debugging or navigation.
struct MapRadiusView: View {
    
    // MARK: - Bindable Monitor
    // Bindable allows two-way data binding between the LocationMonitor and this view
    @Bindable var monitor: LocationMonitor
    // Provides access to userLocation, center coordinate, and radius
    
    // MARK: - Map Camera Position
    @State private var position: MapCameraPosition = .automatic
    // Tracks the camera (view) position of the map
    // Starts as automatic, can be adjusted when the view appears
    
    // MARK: - Body
    var body: some View {
        
        // MARK: - Map
        Map(position: $position) {
            
            // MARK: - Circle Overlay
            // Visualizes the geofence radius
            MapCircle(center: monitor.center, radius: monitor.radius)
                .foregroundStyle(.blue.opacity(0.2)) // Light blue fill with transparency
                .stroke(.blue, lineWidth: 2)          // Blue border line
            
            // MARK: - User Location Annotation
            // Adds a marker for the user's current location
            UserAnnotation()
        }
        
        // MARK: - Map Controls
        // Adds interactive controls for compass, scale, and user location
        .mapControls {
            MapUserLocationButton() // Button to center on user location
            MapCompass()            // Shows compass on map
            MapScaleView()          // Displays scale (distance) on map
        }
        
        // MARK: - Map Camera Setup
        .onAppear {
            // When the view appears, position the map to show the Quad circle fully
            position = .region(
                MKCoordinateRegion(
                    center: monitor.center,
                    latitudinalMeters: monitor.radius * 3,
                    longitudinalMeters: monitor.radius * 3
                )
            )
            // Multiplied by 3 so the circle isn’t too close to edges of the map
        }
    }
}
