//Created by Theron

import SwiftUI
// SwiftUI is Apple's modern framework for building user interfaces.
// It uses a declarative style where we describe what the UI should look like.

import CoreLocation
// CoreLocation provides GPS coordinates, location data,
// and geographic utilities such as latitude and longitude.
// This import is needed so we can access properties like
// monitor.center.latitude and monitor.center.longitude.



// This struct defines a screen in the app used for debugging tools.
// It conforms to the View protocol, meaning it describes UI content.
struct DebugView: View {
    
    
    // MARK: - Environment Variables
    
    
    // @Environment allows the view to access system-provided values.
    // The dismiss function allows this view to close itself
    // when presented as a modal screen or sheet.
    @Environment(\.dismiss) private var dismiss
    
    
    // MARK: - Local State
    
    
    // @State stores local mutable data for this view.
    // If the values inside LocationMonitor change,
    // SwiftUI automatically refreshes the interface.
    @State private var monitor = LocationMonitor()
    
    
    
    // MARK: - UI Layout
    
    
    // body describes the entire user interface for this screen.
    var body: some View {
        
        // NavigationStack provides navigation features such as:
        // • titles
        // • navigation bars
        // • toolbars
        // It replaces older NavigationView in modern SwiftUI.
        NavigationStack {
            
            // VStack stacks elements vertically.
            VStack {
                
                
                // MARK: - Quad Status Message
                
                
                // Check if the user is currently inside the quad geofence.
                if monitor.isUserInQuad {
                    
                    Text("📍 You are in the Quad!")
                        .font(.headline)
                        .padding()
                        
                        // Expands the view horizontally.
                        .frame(maxWidth: .infinity)
                        
                        // Green background indicating success / active state.
                        .background(Color.green.opacity(0.2))
                        
                        // Green text color.
                        .foregroundStyle(.green)
                        
                        // Rounded corners.
                        .cornerRadius(10)
                        
                        // Extra spacing around the view.
                        .padding()
                }
                
                
                
                // MARK: - Radius Map Visualization
                
                
                // MapRadiusView is a custom view that likely shows
                // the quad center and radius visually on a map.
                MapRadiusView(monitor: monitor)
                
                    // Set the height of the map.
                    .frame(height: 300)
                    
                    // Round the edges of the map.
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Add padding around the map.
                    .padding()
                
                
                
                // MARK: - Debug Controls List
                
                
                // List creates a scrollable table interface,
                // commonly used in settings or debugging panels.
                List {
                    
                    
                    // MARK: - Radius Adjustment Section
                    
                    
                    // A section groups related controls together.
                    Section("Geofence Radius") {
                        
                        // VStack holds the slider and label.
                        VStack {
                            
                            // Display the current radius value in meters.
                            Text("\(Int(monitor.radius)) meters")
                            
                            
                            // Slider allows interactive adjustment of the radius.
                            Slider(
                                value: $monitor.radius,
                                
                                // Minimum radius = 50 meters
                                // Maximum radius = 1000 meters
                                in: 50...1000,
                                
                                // Slider moves in increments of 10 meters.
                                step: 10
                            )
                        }
                    }
                    
                    
                    
                    // MARK: - Technical Debug Info
                    
                    
                    Section("Technical Info") {
                        
                        // LabeledContent displays a key/value pair.
                        // This is similar to settings-style UI.
                        
                        LabeledContent(
                            "Latitude",
                            value: "\(monitor.center.latitude)"
                        )
                        
                        LabeledContent(
                            "Longitude",
                            value: "\(monitor.center.longitude)"
                        )
                    }
                }
            }
            
            
            
            // MARK: - Navigation Bar
            
            
            // Title shown at the top of the screen.
            .navigationTitle("Developer Tools")
            
            
            
            // MARK: - Toolbar Controls
            
            
            .toolbar {
                
                // ToolbarItem places a button in the navigation bar.
                ToolbarItem(placement: .topBarLeading) {
                    
                    // Button closes the debug screen.
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            
            
            
            // MARK: - Async Startup Task
            
            
            // .task runs asynchronous code when the view appears.
            // Here we start the geofence monitoring system.
            .task {
                await monitor.startLocationMonitoring()
            }
        }
    }
}
