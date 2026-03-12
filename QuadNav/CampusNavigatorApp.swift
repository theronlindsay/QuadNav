

import SwiftUI

@main
struct CampusNavigatorApp: App {
    
    @State private var monitor = LocationMonitor()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(monitor)
                .task {
                    await monitor.startLocationMonitoring()
                }
        }
    }
}
