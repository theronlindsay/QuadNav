//
// CampusNavigatorApp.swift
//

import SwiftUI

// MARK: - App Entry Point
@main
struct CampusNavigatorApp: App {
    
    // Location monitor shared across the app
    @State private var monitor = LocationMonitor()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(monitor) // Provide monitor to child views
                .task {
                    await monitor.startLocationMonitoring() // Start location tracking on launch
                }
        }
    }
}
