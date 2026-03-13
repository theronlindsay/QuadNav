//
// ARNavigationView.swift
// Created by Brandon Williams & Amber
//

import SwiftUI
import RealityKit
// RealityKit provides 3D AR rendering, anchors, and entities for augmented reality experiences.

// MARK: - AR Navigation View
// This view displays the AR scene along with optional overlays.
// It links the AR session manager and location monitor from the parent view.
struct ARNavigationView: View {
    
    // MARK: - Bindable Properties
    // Bindable allows SwiftUI to automatically update the view whenever these properties change
    @Bindable var sessionManager: ARSessionManager   // Manages AR session & arrow entity
    @Bindable var locationMonitor: LocationMonitor  // Tracks user location and Quad geofence
    
    // MARK: - Body
    var body: some View {
        ZStack {
            
            // MARK: - AR Scene
            // ARViewContainer bridges UIKit's ARView into SwiftUI
            ARViewContainer(sessionManager: sessionManager)
                .edgesIgnoringSafeArea(.all) // Fill the whole screen
            
            // MARK: - Bottom Overlay
            VStack {
                Spacer() // Push overlay to bottom
                
                HStack {
                    
                    // MARK: Navigation Status Text
                    if locationMonitor.isUserInQuad {
                        // User is inside the Quad
                        Text("Destination Reached")
                            .padding(8)
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    } else {
                        // User is still navigating
                        Text("Navigating...")
                            .padding(8)
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                    
                    // MARK: Optional 2D Arrow Overlay
                    /*
                    Image(systemName: "location.north.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(sessionManager.relativeBearing))
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                    */
                    // This is commented out because the AR arrow is already in 3D.
                    // Can be enabled if a 2D directional indicator is desired.
                }
                .padding()
            }
        }
    }
}

// MARK: - ARView Container
// This struct embeds RealityKit's ARView inside SwiftUI.
// It allows SwiftUI to display 3D AR content.
struct ARViewContainer: UIViewRepresentable {
    
    var sessionManager: ARSessionManager
    
    // Called once when the view is created
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        sessionManager.setupARView(in: arView) // Configure AR session
        return arView
    }
    
    // Called whenever SwiftUI wants to update the view
    func updateUIView(_ uiView: ARView, context: Context) {}
}
