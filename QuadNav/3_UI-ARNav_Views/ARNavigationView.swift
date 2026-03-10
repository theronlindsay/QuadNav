//
//  ARNavigationView.swift
//  QuadNav
//
//  Created by Brandon Williams on 3/9/26.
//

import SwiftUI
import RealityKit

struct ARNavigationView: UIViewRepresentable {
    var targetBearing: Double
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        context.coordinator.setup(arView: arView)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Continuously pass the bearing from NavigationManager to the AR manager
        context.coordinator.update(bearing: targetBearing)
    }
    
    func makeCoordinator() -> ARSessionManager {
        ARSessionManager()
    }
}
