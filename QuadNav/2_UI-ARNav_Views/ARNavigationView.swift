//
// ARNavigationView.swift
//

import SwiftUI
import RealityKit

// MARK: - AR Navigation View
struct ARNavigationView: View {
    @Bindable var sessionManager: ARSessionManager
    @Bindable var locationMonitor: LocationMonitor
    
    var body: some View {
        ZStack {
            // AR Scene
            ARViewContainer(sessionManager: sessionManager)
                .edgesIgnoringSafeArea(.all)
            
            // Bottom overlay for navigation status
            VStack {
                Spacer()
                
                HStack {
                    // Navigation status text
                    if locationMonitor.isUserInQuad {
                        Text("Destination Reached")
                            .padding(8)
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    } else {
                        Text("Navigating...")
                            .padding(8)
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                    
                    // Optional 2D arrow in AR — uncomment if needed
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
                }
                .padding()
            }
        }
    }
}

// MARK: - ARView Container
struct ARViewContainer: UIViewRepresentable {
    var sessionManager: ARSessionManager
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        sessionManager.setupARView(in: arView)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}
