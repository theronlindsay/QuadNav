//
// MapRadiusView.swift
// Created by Theron
//

import SwiftUI
import MapKit

// MARK: - Map Radius View
// Displays a map highlighting a circular geofence area
struct MapRadiusView: View {
    
    // MARK: Properties
    
    /// Monitors location and geofence data
    @Bindable var monitor: LocationMonitor
    
    /// Controls the map camera position
    @State private var position: MapCameraPosition = .automatic
    
    // MARK: Body
    
    var body: some View {
        Map(position: $position) {
            
            // Draw geofence circle
            MapCircle(center: monitor.center, radius: monitor.radius)
                .foregroundStyle(.blue.opacity(0.2))
                .stroke(.blue, lineWidth: 2)
            
            // User location marker
            UserAnnotation()
        }
        
        // Map controls for user interaction
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        
        // Center map on geofence region when view appears
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
