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
            let model = Entity()
            let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
            let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
            model.components.set(ModelComponent(mesh: mesh, materials: [material]))
            model.position = [0, 0.05, 0]

            // Create horizontal plane anchor for the content
            let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
            anchor.addChild(model)

            // Add the horizontal plane anchor to the scene
            content.add(anchor)

            content.camera = .spatialTracking
            }
            .edgesIgnoringSafeArea(.all)
            
            // UI Overlay
            VStack {
                HStack(alignment: .center) {
                    Text("QuadNav")
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
