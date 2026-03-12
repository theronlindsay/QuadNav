//
// GroundArrowEntity.swift
//

import RealityKit
import UIKit

// Simple ground arrow made from a box (shaft) and cone (head)
class GroundArrowEntity: Entity, HasModel {


// MARK: - Initialization

required init() {
    super.init()
    
    // MARK: Shaft
    
    let shaftMesh = MeshResource.generateBox(width: 0.12, height: 0.04, depth: 0.4)
    let shaft = ModelEntity(mesh: shaftMesh, materials: [UnlitMaterial(color: .systemBlue)])
    shaft.position = [0, 0.02, 0.2] // Slight lift to avoid floor clipping
    
    // MARK: Head
    
    let headMesh = MeshResource.generateCone(height: 0.25, radius: 0.15)
    let head = ModelEntity(mesh: headMesh, materials: [UnlitMaterial(color: .systemOrange)])
    
    // Place head at the front of the shaft
    head.position = [0, 0.02, -0.1]
    
    // Rotate cone so it points forward (-Z)
    head.orientation = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])
    
    // MARK: Assembly
    
    self.addChild(shaft)
    self.addChild(head)
}

}
