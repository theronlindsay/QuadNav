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
    
    @Environment(\.dismiss) private var dismiss
    @Environment(LocationMonitor.self) private var monitor
        
    var body: some View {
        NavigationStack {
            VStack {
                
                if monitor.isUserInQuad {
                    Text("📍 You are inside the Quad")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.2))
                        .foregroundStyle(.green)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                MapRadiusView(monitor: monitor)
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()

                List {

                    Section("Geofence Radius") {

                        VStack(alignment: .leading) {

                            Text("Radius: \(Int(monitor.radius)) m")

                            Slider(
                                value: Bindable(monitor)
                                    .radius,
                                in: 50...3000,
                                step: 10
                            )
                        }
                    }

                    Section("Quad Center") {

                        LabeledContent(
                            "Latitude",
                            value: "\(monitor.center.latitude)"
                        )

                        LabeledContent(
                            "Longitude",
                            value: "\(monitor.center.longitude)"
                        )
                    }

                    if let location = monitor.userLocation {

                        Section("Current Location") {

                            LabeledContent(
                                "Latitude",
                                value: "\(location.coordinate.latitude)"
                            )

                            LabeledContent(
                                "Longitude",
                                value: "\(location.coordinate.longitude)"
                            )
                        }
                    }
                }
            }

            .navigationTitle("Developer Tools")

            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }

            .task(id: monitor.radius) {
                await monitor.startLocationMonitoring()
            }

            .onDisappear {
                monitor.stop()
            }
        }
    }
}

#Preview{
    DebugView()
        .environment(LocationMonitor())
}
