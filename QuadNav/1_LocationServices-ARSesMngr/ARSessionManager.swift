import ARKit
import RealityKit
import Observation

@Observable
class ARSessionManager: NSObject, ARSessionDelegate {
    var arView: ARView?
    var targetBearing: Double = 0.0
    var relativeBearing: Double = 0.0
    
    // Using your custom entity type
    private var arrowEntity: GroundArrowEntity?
    private var isArrowPlaced: Bool = false
    
    func setupARView(in view: ARView) {
        self.arView = view
        view.session.delegate = self
        
        let configuration = ARWorldTrackingConfiguration()
        // FIX: Force AR space to align with True North
        configuration.worldAlignment = .gravityAndHeading
        configuration.planeDetection = [.horizontal]
        
        view.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        setupTapGesture(for: view)
    }
    
    private func setupTapGesture(for view: ARView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        guard let arView = arView else { return }
        let tapLocation = sender.location(in: arView)
        
        let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = results.first {
            placeArrow(at: firstResult.worldTransform)
        }
    }
    
    private func placeArrow(at transform: simd_float4x4) {
        // Remove old anchor/arrow if it exists
        if let currentAnchor = arView?.scene.anchors.first(where: { $0.name == "ArrowAnchor" }) {
            arView?.scene.removeAnchor(currentAnchor)
        }
        
        // Reset transform columns to ensure no weird scaling/skewing from the raycast
        var fixedTransform = transform
        fixedTransform.columns.0 = [1,0,0,0]
        fixedTransform.columns.1 = [0,1,0,0]
        fixedTransform.columns.2 = [0,0,1,0]
        
        let anchor = AnchorEntity(world: fixedTransform)
        anchor.name = "ArrowAnchor"
        
        // Use YOUR 3D object
        let arrow = GroundArrowEntity()
        anchor.addChild(arrow)
        
        self.arrowEntity = arrow
        arView?.scene.addAnchor(anchor)
        isArrowPlaced = true
        
        updateArrowRotation()
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard isArrowPlaced, let arrow = arrowEntity else { return }
        
        // 1. Position Logic: Auto-reposition if user gets too close
        let cameraTransform = frame.camera.transform
        let cameraPos = simd_make_float3(cameraTransform.columns.3.x, cameraTransform.columns.3.y, cameraTransform.columns.3.z)
        let arrowPos = arrow.position(relativeTo: nil)
        
        if simd_distance(cameraPos, arrowPos) < 1.0 {
            let forward = simd_make_float3(cameraTransform.columns.2.x, cameraTransform.columns.2.y, cameraTransform.columns.2.z)
            let newPosition = cameraPos - (forward * 2.0)
            arrow.setPosition(newPosition, relativeTo: nil)
        }
        
        // 2. Rotation Logic: Use your North-aligned coordinate fix
        updateArrowRotation()
    }
    
    private func updateArrowRotation() {
        guard let arrow = arrowEntity else { return }
        // Driving the rotation by the absolute bearing to the building
        let radians = Float(targetBearing) * (.pi / 180)
        arrow.orientation = simd_quatf(angle: -radians, axis: [0, 1, 0])
    }
}
