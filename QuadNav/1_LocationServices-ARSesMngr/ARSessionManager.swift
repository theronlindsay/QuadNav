import ARKit
import RealityKit
import SwiftUI

class ARSessionManager: NSObject, ARSessionDelegate {
    weak var arView: ARView?
    var arrowEntity: GroundArrowEntity?
    var currentBearing: Double = 0.0 {
        didSet { updateArrowRotation() }
    }
    
    func setup(arView: ARView) {
        self.arView = arView
        arView.session.delegate = self
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        arView.session.run(config)
        
        // Add Tap Gesture to place the arrow
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        arView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        guard let arView = arView else { return }
        
        let tapLocation = sender.location(in: arView)
        
        // Raycast specifically for horizontal planes
        let results = arView.raycast(from: tapLocation, allowing: .existingPlaneGeometry, alignment: .horizontal)
        
        if let firstResult = results.first {
            placeArrow(at: firstResult.worldTransform)
        }
    }
    
    private func placeArrow(at transform: simd_float4x4) {
        // Remove old arrow if it exists
        if let currentAnchor = arView?.scene.anchors.first(where: { $0.name == "ArrowAnchor" }) {
            arView?.scene.removeAnchor(currentAnchor)
        }
        
        let anchor = AnchorEntity(world: transform)
        anchor.name = "ArrowAnchor"
        
        let arrow = GroundArrowEntity()
        anchor.addChild(arrow)
        self.arrowEntity = arrow
        
        arView?.scene.addAnchor(anchor)
        updateArrowRotation()
    }
    
    func update(bearing: Double) {
        self.currentBearing = bearing
        updateArrowRotation()
    }
    
    private func updateArrowRotation() {
        // Rotate around Y to point toward targetBearing
        let radians = Float(currentBearing) * (.pi / 180.0)
        arrowEntity?.transform.rotation = simd_quatf(angle: -radians, axis: [0, 1, 0])
    }
}
