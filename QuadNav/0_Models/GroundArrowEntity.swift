//
// GroundArrowEntity.swift
// Created by Brandon Williams
//

import RealityKit // Provides 3D rendering and entity/component system for AR
import UIKit       // Needed for colors like .systemBlue and .systemOrange

// MARK: - GroundArrowEntity
// This class creates a 3D arrow model for AR navigation.
// It inherits from Entity (basic 3D object in RealityKit) and has a model.
class GroundArrowEntity: Entity, HasModel {
    
    // MARK: Initialization
    required init() {
        super.init() // Call the parent class initializer
        
        // --- Shaft ---
        // This is the long rectangular part of the arrow
        let shaftMesh = MeshResource.generateBox(
            width: 0.12, height: 0.04, depth: 0.4
        )
        let shaft = ModelEntity(mesh: shaftMesh, materials: [
            UnlitMaterial(color: .systemBlue) // UnlitMaterial keeps the color bright regardless of lighting
        ])
        shaft.position = [0, 0.02, 0.2] // Lift slightly off the floor to avoid z-fighting
        
        // --- Head (Cone) ---
        // The cone represents the arrowhead
        let headMesh = MeshResource.generateCone(
            height: 0.25, radius: 0.15
        )
        let head = ModelEntity(mesh: headMesh, materials: [
            UnlitMaterial(color: .systemOrange)
        ])
        
        // Position the head in front of the shaft
        head.position = [0, 0.02, -0.1]
        
        // Rotate the cone so it points forward (-Z direction)
        // RealityKit cones point up (+Y) by default
        head.orientation = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])
        
        // Add both parts to the parent entity
        self.addChild(shaft)
        self.addChild(head)
    }
}
