//
// CampusNavigatorApp.swift
// Created by Brandon Williams & Amber
//

import SwiftUI
// SwiftUI: Apple's framework for building user interfaces declaratively

// MARK: - Main App Entry Point
// Every SwiftUI app starts from a struct annotated with @main
// This struct conforms to the App protocol and defines the app's scenes.
@main
struct CampusNavigatorApp: App {
    
    // MARK: - Shared LocationMonitor
    // Create a single instance of LocationMonitor to share across the app
    @State private var monitor = LocationMonitor()
    
    // MARK: - Scene Definition
    // Defines the content displayed in the app's windows
    var body: some Scene {
        
        // MARK: - WindowGroup
        // A container for the main content of the app
        WindowGroup {
            
            // MARK: - ContentView
            // The main view of the app
            ContentView()
                // Pass the shared LocationMonitor down the view hierarchy
                // This makes it accessible via @Environment(LocationMonitor.self)
                .environment(monitor)
                
                // MARK: - Start Location Monitoring
                // Run an asynchronous task to start location updates when the app launches
                .task {
                    await monitor.startLocationMonitoring()
                    // This ensures that GPS updates and geofence monitoring begin immediately
                }
        }
    }
}
