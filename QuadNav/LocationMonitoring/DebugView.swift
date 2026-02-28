//
//  ContentView.swift
//  LocationMonitoring
//
//  Created by Theron on 2/26/26.
//

import SwiftUI
import _LocationEssentials

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
                        .padding(.horizontal)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                MapRadiusView(monitor: monitor)
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
                
                List {
                    Section("Monitor Settings") {
                        VStack(alignment: .leading) {
                            Text("Radius: \(Int(monitor.radius))m")
                            Slider(value: Bindable(monitor).radius, in: 50...2000, step: 10)
                        }
                    }
                    
                    Section("Monitor Info") {
                        LabeledContent("Latitude", value: "\(monitor.center.latitude)")
                        LabeledContent("Longitude", value: "\(monitor.center.longitude)")
                        LabeledContent("Radius", value: "\(monitor.radius)m")
                    }
                    
                    if let userLocation = monitor.userLocation {
                        Section("Current Location") {
                            LabeledContent("Latitude", value: "\(userLocation.coordinate.latitude)")
                            LabeledContent("Longitude", value: "\(userLocation.coordinate.longitude)")
                        }
                    }
                }
            }
            .navigationTitle("Location Monitor")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .task {
                await monitor.startLocationMonitoring()
            }
            .onDisappear {
                monitor.stop()
            }
        }
    }
}

#Preview {
    DebugView()
}
