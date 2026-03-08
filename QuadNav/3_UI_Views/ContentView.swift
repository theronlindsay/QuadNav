//Created by Brandon Williams & Amber

import SwiftUI
// SwiftUI is Apple's framework for building user interfaces
// using a declarative programming style (you describe what the UI
// should look like rather than manually updating it).


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
    
    
    // MARK: - UI Layout
    
    
    // body defines the entire layout of the view.
    // SwiftUI recomputes this whenever state changes.
    var body: some View {
        
        // ZStack layers views on top of each other
        // (like stacking transparent sheets).
        ZStack {
            
            
            // MARK: - Map Background
            
            
            // Custom MapView showing the campus and buildings.
            MapView(
                
                // Binding allows MapView to modify the selected building.
                // The "$" means this is a two-way connection.
                selectedBuilding: $navManager.selectedBuilding,
                
                // Pass the user's location to the map.
                userLocation: navManager.userLocation,
                
                // Provide the list of campus buildings.
                buildings: Building.campusBuildings
            )
            
            // Makes the map extend behind safe areas (like the notch).
            .ignoresSafeArea()
            
            
            
            // MARK: - Overlay UI
            
            
            // VStack stacks elements vertically.
            VStack {
                
                
                // MARK: - Destination Information
                
                
                // Inner vertical stack for building information.
                VStack(spacing: 4) {
                    
                    // Display selected building name.
                    // If no building is selected, show placeholder text.
                    Text(navManager.selectedBuilding?.name ?? "Select a Building")
                        .font(.headline)
                    
                    
                    // Display the distance to the selected building.
                    // The distance is converted to an integer for cleaner display.
                    Text("\(Int(navManager.distanceToTarget)) meters away")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // Add padding around the text block.
                .padding()
                
                // Adds a translucent background (frosted glass effect).
                .background(.ultraThinMaterial)
                
                // Rounds the corners of the background panel.
                .cornerRadius(12)
                
                
                
                // Push the next content toward the center of the screen.
                Spacer()
                
                
                
                // MARK: - Direction Arrow
                
                
                // Custom view that rotates an arrow toward the target building.
                DirectionArrowView(angle: navManager.targetBearing)
                
                    // Define the size of the arrow view.
                    .frame(width: 140, height: 140)
                
                
                
                // Another spacer to push content apart vertically.
                Spacer()
                
                
                
                // MARK: - Radius / Geofence View
                
                
                // Displays information about the quad geofence.
                MapRadiusView(monitor: locationMonitor)
                
                    // Height of this UI component.
                    .frame(height: 120)
                    
                    // Rounded corners.
                    .cornerRadius(15)
                    
                    // Adds a white border around the component.
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(.white, lineWidth: 2)
                    )
                
                
                
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
    }
}
