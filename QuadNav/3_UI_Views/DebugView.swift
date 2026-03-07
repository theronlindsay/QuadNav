import SwiftUI
import CoreLocation // Fixed: Added missing import for coordinate properties

struct DebugView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var monitor = LocationMonitor()
    
    var body: some View {
        NavigationStack {
            VStack {
                if monitor.isUserInQuad {
                    Text("📍 You are in the Quad!")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.2))
                        .foregroundStyle(.green)
                        .cornerRadius(10)
                        .padding()
                }
                
                MapRadiusView(monitor: monitor)
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
                
                List {
                    Section("Geofence Radius") {
                        VStack {
                            Text("\(Int(monitor.radius)) meters")
                            Slider(value: $monitor.radius, in: 50...1000, step: 10)
                        }
                    }
                    
                    Section("Technical Info") {
                        LabeledContent("Latitude", value: "\(monitor.center.latitude)")
                        LabeledContent("Longitude", value: "\(monitor.center.longitude)")
                    }
                }
            }
            .navigationTitle("Developer Tools")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .task {
                await monitor.startLocationMonitoring()
            }
        }
    }
}
