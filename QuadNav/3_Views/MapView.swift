//
//  MapView.swift
//  CampusNavigator
//
//  Displays the campus map and allows the user to select a building.
//  Uses MapKit + SwiftUI Annotation views to support tap gestures.
//

import SwiftUI
import MapKit

struct MapView: View {
    
    // MARK: - Inputs from parent view
    @Binding var selectedBuilding: Building?
    
    // Region the map starts centered on
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 43.6020,
                longitude: -116.1990
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.003,
                longitudeDelta: 0.003
            )
        )
    )
    
    // List of buildings to display
    let buildings: [Building]
    
    
    var body: some View {
        
        Map(position: $position) {
            
            // Generate map markers for each building
            ForEach(buildings) { building in
                
                Annotation(building.name,
                           coordinate: building.coordinate) {
                    
                    VStack(spacing: 4) {
                        
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundStyle(.red)
                        
                        Text(building.name)
                            .font(.caption2)
                            .padding(4)
                            .background(.thinMaterial)
                            .cornerRadius(6)
                    }
                    .onTapGesture {
                        selectedBuilding = building
                    }
                }
            }
        }
    }
}
