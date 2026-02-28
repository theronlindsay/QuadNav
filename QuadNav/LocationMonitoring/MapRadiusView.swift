//
//  MapRadiusView.swift
//  LocationMonitoring
//
//  Created by Theron on 2/27/26.
//

import SwiftUI
import MapKit

struct MapRadiusView: View {
    var monitor: LocationMonitor
    
    @State private var position: MapCameraPosition = .automatic
    
    var body: some View {
        Map(position: $position) {
            // Geofence area
            MapCircle(center: monitor.center, radius: monitor.radius)
                .foregroundStyle(.blue.opacity(0.3))
                .stroke(.blue, lineWidth: 2)
            
            // User location
            UserAnnotation()
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .onAppear {
            // Center the map on the geofence initially
            position = .region(MKCoordinateRegion(
                center: monitor.center,
                latitudinalMeters: monitor.radius * 4,
                longitudinalMeters: monitor.radius * 4
            ))
        }
    }
}

#Preview {
    MapRadiusView(monitor: LocationMonitor())
}
