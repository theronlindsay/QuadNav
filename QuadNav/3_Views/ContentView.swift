//
//  ContentView.swift
//  QuadNav
//
//  Main coordinator view for the application.
//  Connects MapView, LocationManager, and BearingCalculator.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    
    // MARK: - Location System
    
    @StateObject private var locationManager = LocationManager()
    
    
    // MARK: - Building Selection
    
    @State private var selectedBuilding: Building?
    
    
    // MARK: - Computed Navigation Values
    
    @State private var targetBearing: Double = 0
    @State private var relativeAngle: Double = 0
    @State private var distance: Double = 0
    
    
    var body: some View {
        
        VStack {
            
            // MARK: - Map View
            
            MapView(
                selectedBuilding: $selectedBuilding,
                buildings: Building.campusBuildings
            )
            .frame(height: 350)
            
            
            Divider()
            
            
            // MARK: - Navigation Info Panel
            
            VStack(spacing: 12) {
                
                if let building = selectedBuilding {
                    
                    Text("Selected Destination")
                        .font(.headline)
                    
                    Text(building.name)
                        .font(.title2)
                        .bold()
                    
                    
                    // Distance Display
                    
                    Text("Distance: \(Int(distance)) meters")
                        .font(.subheadline)
                    
                    
                    // Direction Arrow
                    
                    Image(systemName: "location.north.fill")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(relativeAngle))
                        .animation(.easeInOut(duration: 0.2), value: relativeAngle)
                    
                    
                    Text("Arrow points toward destination")
                        .font(.caption)
                    
                } else {
                    
                    Text("Tap a building on the map")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                }
            }
            .padding()
            
            
            Spacer()
        }
        
        
        // MARK: - Location Permission Request
        
        .onAppear {
            locationManager.requestPermission()
        }
        
        
        // MARK: - React To Location Updates
        
        .onChange(of: locationManager.location) { _, _ in
            updateNavigation()
        }
        
        
        // MARK: - React To Heading Updates
        
        .onChange(of: locationManager.heading) { _, _ in
            updateNavigation()
        }
        
        
        // MARK: - React To Building Selection
        
        .onChange(of: selectedBuilding) { _, _ in
            updateNavigation()
        }
    }
    
    
    // MARK: - Navigation Calculation
    
    private func updateNavigation() {
        
        guard
            let userLocation = locationManager.location,
            let userHeading = locationManager.heading?.trueHeading,
            let building = selectedBuilding
        else { return }
        
        
        // Absolute bearing (north-based)
        
        targetBearing = BearingCalculator.bearing(
            from: userLocation.coordinate,
            to: building.coordinate
        )
        
        
        // Arrow rotation relative to user direction
        
        relativeAngle = BearingCalculator.relativeAngle(
            userHeading: userHeading,
            targetBearing: targetBearing
        )
        
        
        // Distance to building
        
        distance = BearingCalculator.distance(
            from: userLocation,
            to: building.coordinate
        )
    }
}
