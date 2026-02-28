//
//  ContentView.swift
//  QuadNav
//

import SwiftUI
import RealityKit

struct ContentView : View {
    @State private var showDebugMenu = false

    var body: some View {
        ZStack {
            RealityView { content in
                // Create a cube model
                let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
                let material = SimpleMaterial(color: .orange, roughness: 0.15, isMetallic: true)
                let model = ModelEntity(mesh: mesh, materials: [material])
                
                // Position the model 0.5 meters in front of the camera
                // In RealityKit, -Z is forward.
                model.position = [0, 0, -0.5]
                
                // Add directly to the content so it shows up without plane detection
                content.add(model)
            }
            .edgesIgnoringSafeArea(.all)
            
            // UI Overlay
            VStack {
                HStack(alignment: .center) {
                    Text("QuadNav Reality View")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                    
                    Spacer()
                    
                    Button {
                        showDebugMenu = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showDebugMenu) {
            DebugView()
        }
    }

}

#Preview {
    ContentView()
}
