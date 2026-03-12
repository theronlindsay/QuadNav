//
// ARSessionManager.swift
//

import ARKit
import RealityKit
import Observation

// Manages AR session setup and arrow placement/orientation
@Observable
class ARSessionManager: NSObject, ARSessionDelegate {


// MARK: - Properties

var arView: ARView?
var targetBearing: Double = 0.0
var relativeBearing: Double = 0.0

private var arrowEntity: GroundArrowEntity?
private var isArrowPlaced: Bool = false


// MARK: - AR Setup

func setupARView(in view: ARView) {
    self.arView = view
    view.session.delegate = self
    
    let configuration = ARWorldTrackingConfiguration()
    configuration.worldAlignment = .gravityAndHeading // Align AR world with True North
    configuration.planeDetection = [.horizontal]
    
    view.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    setupTapGesture(for: view)
}


// MARK: - Gesture Handling

private func setupTapGesture(for view: ARView) {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    view.addGestureRecognizer(tapGesture)
}

@objc private func handleTap(_ sender: UITapGestureRecognizer) {
    guard let arView = arView else { return }
    let tapLocation = sender.location(in: arView)
    
    // Raycast to find a horizontal surface
    let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
    
    if let firstResult = results.first {
        placeArrow(at: firstResult.worldTransform)
    }
}


// MARK: - Arrow Placement

private func placeArrow(at transform: simd_float4x4) {
    
    // Remove existing arrow anchor
    if let currentAnchor = arView?.scene.anchors.first(where: { $0.name == "ArrowAnchor" }) {
        arView?.scene.removeAnchor(currentAnchor)
    }
    
    // Normalize transform to avoid scaling/skew from raycast
    var fixedTransform = transform
    fixedTransform.columns.0 = [1,0,0,0]
    fixedTransform.columns.1 = [0,1,0,0]
    fixedTransform.columns.2 = [0,0,1,0]
    
    let anchor = AnchorEntity(world: fixedTransform)
    anchor.name = "ArrowAnchor"
    
    let arrow = GroundArrowEntity()
    anchor.addChild(arrow)
    
    self.arrowEntity = arrow
    arView?.scene.addAnchor(anchor)
    isArrowPlaced = true
    
    updateArrowRotation()
}


// MARK: - ARSessionDelegate

func session(_ session: ARSession, didUpdate frame: ARFrame) {
    guard isArrowPlaced, let arrow = arrowEntity else { return }
    
    // Camera position
    let cameraTransform = frame.camera.transform
    let cameraPos = simd_make_float3(
        cameraTransform.columns.3.x,
        cameraTransform.columns.3.y,
        cameraTransform.columns.3.z
    )
    
    let arrowPos = arrow.position(relativeTo: nil)
    
    // Reposition arrow if user gets too close
    if simd_distance(cameraPos, arrowPos) < 1.0 {
        
        let forward = simd_make_float3(
            cameraTransform.columns.2.x,
            cameraTransform.columns.2.y,
            cameraTransform.columns.2.z
        )
        
        let newPosition = cameraPos - (forward * 2.0)
        arrow.setPosition(newPosition, relativeTo: nil)
    }
    
    // Update arrow orientation
    updateArrowRotation()
}


// MARK: - Arrow Orientation

private func updateArrowRotation() {
    guard let arrow = arrowEntity else { return }
    
    let radians = Float(targetBearing) * (.pi / 180)
    arrow.orientation = simd_quatf(angle: -radians, axis: [0, 1, 0])
}


}
