//
// DebugView.swift
// Created by Theron
//

import SwiftUI
import CoreLocation

// MARK: - Developer Tools View
// Shows debugging info for location, geofence, and Quad monitoring
struct DebugView: View {
    
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    @Environment(LocationMonitor.self) private var monitor
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack {
                
                // Status if user is inside the Quad
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

                // Map radius preview
                MapRadiusView(monitor: monitor)
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()

                // Settings list
                List {
                    
                    // MARK: Geofence Radius
                    Section("Geofence Radius") {
                        VStack(alignment: .leading) {
                            Text("Radius: \(Int(monitor.radius)) m")
                            
                            Slider(
                                value: Bindable(monitor).radius,
                                in: 50...3000,
                                step: 10
                            )
                        }
                    }
                    
                    // MARK: Quad Center
                    Section("Quad Center") {
                        LabeledContent("Latitude", value: "\(monitor.center.latitude)")
                        LabeledContent("Longitude", value: "\(monitor.center.longitude)")
                    }
                    
                    // MARK: Current Location
                    if let location = monitor.userLocation {
                        Section("Current Location") {
                            LabeledContent("Latitude", value: "\(location.coordinate.latitude)")
                            LabeledContent("Longitude", value: "\(location.coordinate.longitude)")
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
            
            // Start monitoring when view appears
            .task(id: monitor.radius) {
                await monitor.startLocationMonitoring()
            }
            
            // Stop monitoring when view disappears
            .onDisappear {
                monitor.stop()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    DebugView()
        .environment(LocationMonitor())
}
