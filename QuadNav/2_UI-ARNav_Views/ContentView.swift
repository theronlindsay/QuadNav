//
// ContentView.swift
// Created by Brandon Williams & Amber
//

import SwiftUI
import CoreLocation
import ARKit

// MARK: - Main Content View
// This is the main screen of the app. It decides what the user sees based on the selected navigation mode.
// It displays map-only, split-screen, or full AR view and overlays navigation UI like distance and arrows.
struct ContentView: View {

    // MARK: - State Objects
    // These objects hold the live data that drives the UI
    @State private var navManager = NavigationManager()     // Manages GPS, heading, and building navigation
    @State private var locationMonitor = LocationMonitor()  // Tracks if user is inside the Quad
    @State private var arSessionManager = ARSessionManager() // Manages AR session & 3D arrow
    @State private var recenterTrigger = UUID()             // UUID that triggers map recentering

    @State private var currentMode: ARMode = .map           // Which navigation mode is currently active
    @State private var showDebugView = false               // Whether to show developer tools
    @State private var showQuadDistance = false            // Whether to show distance to the Quad center

    // MARK: - Helper Computed Properties

    /// Calculates distance from user to Quad center
    var distanceToQuad: Double {
        guard let userLocation = navManager.userLocation else { return 0 }

        let quadCenter = CLLocation(
            latitude: locationMonitor.center.latitude,
            longitude: locationMonitor.center.longitude
        )

        return userLocation.distance(from: quadCenter)
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            // MARK: Background View Layer
            // The main content (AR or Map) is rendered first so overlays appear on top

            if currentMode == .ar {
                // Full-screen AR view
                ARNavigationView(
                    sessionManager: arSessionManager,
                    locationMonitor: locationMonitor
                )
                .ignoresSafeArea() // Fill the entire screen
            } else if currentMode == .split {
                // Split-screen: top half AR, bottom half map
                VStack(spacing: 0) {
                    
                    // Top: AR view
                    ARNavigationView(
                        sessionManager: arSessionManager,
                        locationMonitor: locationMonitor
                    )
                    .frame(maxHeight: UIScreen.main.bounds.height / 2)
                    
                    // Bottom: Map view
                    ZStack {
                        MapView(
                            selectedBuilding: $navManager.selectedBuilding,
                            userLocation: navManager.userLocation,
                            buildings: Building.campusBuildings,
                            recenterTrigger: recenterTrigger
                        )
                        
                        // Overlay the direction arrow if a building is selected
                        if navManager.selectedBuilding != nil {
                            DirectionArrowView(angle: navManager.relativeBearing)
                                .frame(width: 140, height: 140)
                                .shadow(radius: 5)
                                .animation(.spring, value: navManager.targetBearing)
                        }
                    }
                }
                .ignoresSafeArea()
            } else {
                // Map-only view
                ZStack {
                    MapView(
                        selectedBuilding: $navManager.selectedBuilding,
                        userLocation: navManager.userLocation,
                        buildings: Building.campusBuildings,
                        recenterTrigger: recenterTrigger
                    )
                    
                    if navManager.selectedBuilding != nil {
                        DirectionArrowView(angle: navManager.relativeBearing)
                            .frame(width: 140, height: 140)
                            .shadow(radius: 5)
                            .animation(.spring, value: navManager.targetBearing)
                    }
                }
                .ignoresSafeArea()
            }

            // MARK: - Overlay UI Layer
            // Overlays navigation controls, distance info, and building selection on top of AR/Map
            VStack(spacing: currentMode == .map ? 6 : 12) {
                
                // Top: Mode Picker (Map / Split / AR)
                Picker("Navigation Mode", selection: $currentMode) {
                    Text("Map").tag(ARMode.map)
                    Text("Split").tag(ARMode.split)
                    Text("AR").tag(ARMode.ar)
                }
                .pickerStyle(.segmented) // Makes it a horizontal segmented control
                .padding()
                .background(.ultraThinMaterial) // Blurs background lightly
                .cornerRadius(12)
                .padding(.horizontal)

                // Middle: Building info and distance
                VStack(spacing: currentMode == .map ? 2 : 4) {
                    HStack {
                        // Show selected building name or placeholder
                        Text(navManager.selectedBuilding?.name ?? "Select a Building")
                            .font(.headline)

                        Spacer()

                        // Developer Tools Button
                        Button {
                            showDebugView = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                        }
                    }

                    // Distance to selected building
                    Text("\(Int(navManager.distanceToTarget)) meters away")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    // Optional: Show distance to Quad center
                    if showQuadDistance {
                        Text("Quad Distance: \(Int(distanceToQuad)) m")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)

                Spacer()

                // Bottom Controls: Recenter + Building Picker
                HStack {
                    // Recenter Map Button
                    Button {
                        recenterTrigger = UUID() // Changing this triggers map to recenter
                    } label: {
                        Label("Recenter", systemImage: "location.fill")
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .cornerRadius(10)
                    }

                    Spacer()

                    // Building Selection Menu
                    Picker("Target", selection: $navManager.selectedBuilding) {
                        // Default placeholder
                        Text("📍 Select Destination")
                            .tag(nil as Building?)
                        
                        // Populate menu with campus buildings
                        ForEach(Building.campusBuildings) { building in
                            Text(building.name)
                                .tag(building as Building?)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(5)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                }
            }
            .padding(.top, currentMode == .map ? 50 : 0) // Adjust overlay for full-map spacing
            .padding()
        }

        // MARK: - Debug Sheet
        .sheet(isPresented: $showDebugView) {
            DebugView() // Developer tools view
        }

        // MARK: - Data Sync
        // Update location monitor when GPS changes
        .onChange(of: navManager.userLocation) { _, newValue in
            if let location = newValue {
                locationMonitor.updateUserLocation(location)
            }
        }

        // Update AR arrow rotation when target bearing changes
        .onChange(of: navManager.targetBearing) { _, newValue in
            arSessionManager.targetBearing = newValue
        }
    }
}
