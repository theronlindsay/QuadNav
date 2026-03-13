//
// DebugView.swift
// Created by Brandon Williams & Amber
//

import SwiftUI
import CoreLocation
// SwiftUI: for building UI
// CoreLocation: to display user's GPS coordinates

// MARK: - DebugView
// Provides a developer interface to monitor user location, geofence radius, and Quad detection.
// Useful for testing and tuning geofence behavior.
struct DebugView: View {
    
    // MARK: - Environment
    
    // Allows the sheet to dismiss itself when the "Close" button is tapped
    @Environment(\.dismiss) private var dismiss
    
    // Pulls the shared LocationMonitor instance from the environment
    // Gives access to user location, geofence radius, Quad center, and Quad status
    @Environment(LocationMonitor.self) private var monitor
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                
                // MARK: - Quad Status
                // Displays a message when the user is inside the Quad geofence
                if monitor.isUserInQuad {
                    Text("📍 You are inside the Quad")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.2))
                        .foregroundStyle(.green)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .transition(
                            .move(edge: .top)
                            .combined(with: .opacity)
                        )
                }
                
                // MARK: - Map Preview
                // Shows the geofence as a circle on a map and the user’s current location
                MapRadiusView(monitor: monitor)
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
                
                // MARK: - List of Debug Info
                List {
                    
                    // Section to adjust the geofence radius
                    Section("Geofence Radius") {
                        VStack(alignment: .leading) {
                            // Show the current radius in meters
                            Text("Radius: \(Int(monitor.radius)) m")
                            
                            // Slider allows live adjustment of the geofence radius
                            // The binding ensures that changing the slider updates LocationMonitor.radius
                            Slider(
                                value: Bindable(monitor).radius,
                                in: 50...3000,
                                step: 10
                            )
                        }
                    }
                    
                    // Section to display Quad center coordinates
                    Section("Quad Center") {
                        LabeledContent("Latitude", value: "\(monitor.center.latitude)")
                        LabeledContent("Longitude", value: "\(monitor.center.longitude)")
                    }
                    
                    // Section to show the user’s current GPS location (if available)
                    if let location = monitor.userLocation {
                        Section("Current Location") {
                            LabeledContent("Latitude", value: "\(location.coordinate.latitude)")
                            LabeledContent("Longitude", value: "\(location.coordinate.longitude)")
                        }
                    }
                }
            }
            
            // MARK: - Navigation Title and Toolbar
            .navigationTitle("Developer Tools")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    // Button to close this sheet
                    Button("Close") { dismiss() }
                }
            }
            
            // MARK: - Start Monitoring
            // Task runs asynchronously to start location monitoring
            // It will run when the view appears or when monitor.radius changes
            .task(id: monitor.radius) {
                await monitor.startLocationMonitoring()
            }
            
            // Stop monitoring when this view disappears to save resources
            .onDisappear {
                monitor.stop()
            }
        }
    }
}

// MARK: - SwiftUI Preview
// Allows Xcode canvas to show a live preview of this view
#Preview {
    DebugView()
        .environment(LocationMonitor())
}
