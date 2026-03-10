import RealityKit
import UIKit

class GroundArrowEntity: Entity, HasModel {
    required init() {
        super.init()
        
        // Use UnlitMaterial so the arrow is bright and not affected by dark shadows
        //let material = UnlitMaterial(color: .systemYellow)
        
        // --- Shaft ---
        let shaftMesh = MeshResource.generateBox(width: 0.12, height: 0.04, depth: 0.4)
        let shaft = ModelEntity(mesh: shaftMesh, materials: [UnlitMaterial(color: .systemBlue)])
        shaft.position = [0, 0.02, 0.2] // Lift slightly so it's not "inside" the floor
        
        // --- Head (Cone) ---
        let headMesh = MeshResource.generateCone(height: 0.25, radius: 0.15)
        let head = ModelEntity(mesh: headMesh, materials: [UnlitMaterial(color: .systemOrange)])
        
        // Position at the front of the shaft
        head.position = [0, 0.02, -0.1]
        
        // Rotate the cone to point FORWARD (-Z).
        // A cone naturally points UP (+Y), so we rotate 90 degrees on X.
        // This flips the cone 180 degrees from its current orientation
        head.orientation = simd_quatf(angle: -.pi / 2, axis: [1, 0, 0])
        
        self.addChild(shaft)
        self.addChild(head)
    }
}
