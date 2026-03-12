//Created by Brandon Williams & Amber

import SwiftUI
// SwiftUI is Apple's framework for building user interfaces
// using a declarative programming style (you describe what the UI
// should look like rather than manually updating it).

import CoreLocation


// A SwiftUI screen is defined as a struct that conforms to the View protocol.
// This tells SwiftUI that this struct describes a piece of UI.
struct ContentView: View {
    
    
    // MARK: - State Objects
    
    
    // @State stores local UI state inside a view.
    // When this value changes, SwiftUI automatically refreshes the UI.
    
    // NavigationManager handles compass direction and distance calculations.
    @State private var navManager = NavigationManager()
    
    // LocationMonitor handles geofence monitoring (quad detection).
    @State private var locationMonitor = LocationMonitor()
    
    @State private var recenterTrigger = UUID()
    
    // MARK: - AR Navigation State
    
    // Tracks the current visual mode (map, split, or ar)
    @State private var currentMode: ARMode = .map
    
    // MARK: - Debug / UI Controls
    
    // Controls whether the developer settings sheet is visible
    @State private var showDebugView = false
    
    // Toggle for showing quad distance (controlled from DebugView)
    @State private var showQuadDistance = false
    
    
    
    // MARK: - Helper: Distance To Quad
    
    var distanceToQuad: Double {
        
        guard let userLocation = navManager.userLocation else { return 0 }
        
        let quadCenter = CLLocation(
            latitude: locationMonitor.center.latitude,
            longitude: locationMonitor.center.longitude
        )
        
        return userLocation.distance(from: quadCenter)
    }
    
    
    
    // MARK: - UI Layout
    
    
    // body defines the entire layout of the view.
    // SwiftUI recomputes this whenever state changes.
    var body: some View {
        
        // ZStack layers views on top of each other
        // (like stacking transparent sheets).
        ZStack {
            
            
            // MARK: - Map / AR Background
            
            // Swaps out the background layer depending on the selected AR mode
            if currentMode == .ar {
                ARNavigationView(
                    targetBearing: navManager.selectedBuilding == nil ? 0 : navManager.targetBearing,
                    deviceHeading: navManager.filteredHeadingForUI ?? 0
                )
                    .ignoresSafeArea()
            } else if currentMode == .split {
                VStack(spacing: 0) {
                    // FIX: Make sure the split AR view gets the same bearing as the full AR view
                    ARNavigationView(
                        targetBearing: navManager.selectedBuilding == nil ? 0 : navManager.targetBearing,
                        deviceHeading: navManager.filteredHeadingForUI ?? 0
                    )
                    
                    // The Map & Arrow combined layer
                    ZStack {
                        MapView(
                            selectedBuilding: $navManager.selectedBuilding,
                            userLocation: navManager.userLocation,
                            buildings: Building.campusBuildings,
                            recenterTrigger: recenterTrigger
                        )
                        
                        // NEW PLACEMENT: Moved DirectionArrow here in ZStack
                        if navManager.selectedBuilding != nil {
                            // FIX: Changed targetBearing to relativeBearing
                            // Now, if the map is rotated, the arrow still points at the building.
                            DirectionArrowView(angle: navManager.relativeBearing)
                                .frame(width: 140, height: 140)
                                .shadow(radius: 5)
                                // Added a small animation so the arrow turns smoothly
                                .animation(.spring, value: navManager.targetBearing)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .ignoresSafeArea()
            } else {
                
                // The main Map & Arrow combined layer
                ZStack {
                    // Custom MapView showing the campus and buildings.
                    MapView(
                        // Binding allows MapView to modify the selected building.
                        selectedBuilding: $navManager.selectedBuilding,
                        // Pass the user's location to the map.
                        userLocation: navManager.userLocation,
                        // Provide the list of campus buildings.
                        buildings: Building.campusBuildings,
                        recenterTrigger: recenterTrigger
                    )
                    
                    // NEW PLACEMENT: Moved DirectionArrow here in ZStack.
                    // It will now be fixed relative to the map background,
                    // but it is still NOT moving dynamically with the user pin.
                    // (That requires complex MapView refactoring).
                    if navManager.selectedBuilding != nil {
                        DirectionArrowView(angle: navManager.relativeBearing)
                            .frame(width: 140, height: 140)
                            .shadow(radius: 5)
                            .animation(.spring, value: navManager.targetBearing)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                // Makes the map extend behind safe areas (like the notch).
                .ignoresSafeArea()
            }
            
            
            
            // MARK: - Overlay UI (This stack stays fixed)
            
            VStack(spacing: 4) {
                
               
                // MARK: - Navigation Mode Selector
                
                Picker("Navigation Mode", selection: $currentMode) {
                    Text("Map").tag(ARMode.map)
                    Text("Split").tag(ARMode.split)
                    Text("AR").tag(ARMode.ar)
                }
                .pickerStyle(.segmented)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // MARK: - Destination Information
                
                
                // Inner vertical stack for building information.
                VStack(spacing: 4) {
                    
                    HStack {
                        
                        // Display selected building name.
                        // If no building is selected, show placeholder text.
                        Text(navManager.selectedBuilding?.name ?? "Select a Building")
                            .font(.headline)
                        
                        Spacer()
                        
                        // Settings / Debug button
                        Button {
                            showDebugView = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                        }
                    }
                    
                    
                    // Display the distance to the selected building.
                    // The distance is converted to an integer for cleaner display.
                    Text("\(Int(navManager.distanceToTarget)) meters away")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    
                    // MARK: - Quad Distance Display
                    
                    if showQuadDistance {
                        
                        Text("Quad Distance: \(Int(distanceToQuad)) m")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Add padding around the text block.
                .padding()
                
                // Adds a translucent background (frosted glass effect).
                .background(.ultraThinMaterial)
                
                // Rounds the corners of the background panel.
                .cornerRadius(12)
                
                
                
                // Push the next content toward the center of the screen.
                Spacer()
                
                
                // OLD PLACEMENT: DirectionArrowView was here in the overlay VStack.
                
                
                
                // Another spacer to push content apart vertically.
                Spacer()
                
                
                
                // MARK: - Radius / Geofence View
                
                
                // Displays information about the quad geofence.
                
                
                
                
                // MARK: - Recenter Map Button
                
                Button {
                    
                    // Resetting selection forces MapView to recenter on user
                    recenterTrigger = UUID()
                    
                } label: {
                    
                    Label("Recenter Map", systemImage: "location.fill")
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
                
                
                
                // MARK: - Destination Picker
                
                
                // Picker allows the user to choose a building destination.
                Picker("Target", selection: $navManager.selectedBuilding) {
                    
                    
                    // Default menu option (no destination selected).
                    Text("📍 Select Destination")
                        .tag(nil as Building?)
                    
                    
                    // Loop through the campus buildings list
                    // and create a menu item for each building.
                    ForEach(Building.campusBuildings) { building in
                        
                        // Display building name in menu.
                        Text(building.name)
                        
                            // Associate this menu option with the building value.
                            .tag(building as Building?)
                    }
                }
                
                // Display the picker as a dropdown menu instead of a wheel.
                .pickerStyle(.menu)
                
                // Add padding around the picker.
                .padding()
                
                // Add frosted background.
                .background(.ultraThinMaterial)
                
                // Rounded edges for the control.
                .cornerRadius(10)
            }
            
            // Adds spacing between the UI and screen edges.
            .padding()
        }
        
        
        // MARK: - Debug Menu Sheet
        
        .sheet(isPresented: $showDebugView) {
            
            DebugView(monitor: locationMonitor)
            
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        
                        Toggle("Show Quad Distance", isOn: $showQuadDistance)
                    }
                }
        }
        
        .onChange(of: navManager.userLocation) { oldValue, newValue in
            if let location = newValue {
                locationMonitor.updateUserLocation(location)
            }
        }
    }
}

