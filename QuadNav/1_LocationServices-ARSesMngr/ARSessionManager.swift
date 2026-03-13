//
// ARSessionManager.swift
// Created by Brandon Williams & Amber
//

import ARKit
import RealityKit
import Observation
// ARKit provides augmented reality tracking and camera integration
// RealityKit handles 3D rendering and entities
// Observation allows @Observable to automatically update SwiftUI when properties change

// MARK: - AR Session Manager
// Manages the AR session, including:
// - Anchoring the 3D arrow in the real world
// - Updating its rotation to point toward the selected building
// - Repositioning the arrow if the user gets too close
@Observable
class ARSessionManager: NSObject, ARSessionDelegate {
    
    // MARK: - Properties
    
    var arView: ARView?                     // The AR scene view
    var targetBearing: Double = 0.0         // Compass bearing toward target building
    var relativeBearing: Double = 0.0       // Difference between device heading and target
    
    private var arrowEntity: GroundArrowEntity?  // The 3D arrow object
    private var isArrowPlaced: Bool = false      // Tracks if the arrow is currently in the scene
    
    // MARK: - Setup ARView
    // Initializes AR session and plane detection
    func setupARView(in view: ARView) {
        self.arView = view
        view.session.delegate = self
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading // Align AR with real world north
        configuration.planeDetection = [.horizontal]     // Detect horizontal surfaces
        
        // Reset AR session to avoid previous anchors or tracking issues
        view.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        setupTapGesture(for: view) // Allow user to tap to place arrow
    }
    
    // MARK: - Tap Gesture
    private func setupTapGesture(for view: ARView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    // Called when user taps the AR view
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        guard let arView = arView else { return }
        let tapLocation = sender.location(in: arView)
        
        // Raycast from the tap location to detect horizontal surfaces
        let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = results.first {
            placeArrow(at: firstResult.worldTransform) // Place arrow at detected surface
        }
    }
    
    // MARK: - Place Arrow
    private func placeArrow(at transform: simd_float4x4) {
        // Remove any existing arrow anchor
        if let currentAnchor = arView?.scene.anchors.first(where: { $0.name == "ArrowAnchor" }) {
            arView?.scene.removeAnchor(currentAnchor)
        }
        
        // Reset transform columns to prevent skewing or scaling from raycast
        var fixedTransform = transform
        fixedTransform.columns.0 = [1,0,0,0]
        fixedTransform.columns.1 = [0,1,0,0]
        fixedTransform.columns.2 = [0,0,1,0]
        
        // Create a new anchor at the transformed location
        let anchor = AnchorEntity(world: fixedTransform)
        anchor.name = "ArrowAnchor"
        
        // Create the 3D arrow entity and add it to the anchor
        let arrow = GroundArrowEntity()
        anchor.addChild(arrow)
        
        self.arrowEntity = arrow
        arView?.scene.addAnchor(anchor)
        isArrowPlaced = true
        
        updateArrowRotation() // Point arrow toward target immediately
    }
    
    // MARK: - Session Updates
    // Called every frame by ARKit
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard isArrowPlaced, let arrow = arrowEntity else { return }
        
        // 1. Position Logic: Move arrow if user gets too close
        let cameraTransform = frame.camera.transform
        let cameraPos = simd_make_float3(cameraTransform.columns.3.x,
                                         cameraTransform.columns.3.y,
                                         cameraTransform.columns.3.z)
        let arrowPos = arrow.position(relativeTo: nil)
        
        if simd_distance(cameraPos, arrowPos) < 1.0 {
            // Move arrow 2 meters in front of the camera
            let forward = simd_make_float3(cameraTransform.columns.2.x,
                                           cameraTransform.columns.2.y,
                                           cameraTransform.columns.2.z)
            let newPosition = cameraPos - (forward * 2.0)
            arrow.setPosition(newPosition, relativeTo: nil)
        }
        
        // 2. Rotation Logic: Point arrow toward target bearing
        updateArrowRotation()
    }
    
    // MARK: - Update Arrow Rotation
    private func updateArrowRotation() {
        guard let arrow = arrowEntity else { return }
        
        // Convert target bearing to radians
        let radians = Float(targetBearing) * (.pi / 180)
        
        // Rotate arrow around Y-axis (-radians because RealityKit's coordinate system)
        arrow.orientation = simd_quatf(angle: -radians, axis: [0, 1, 0])
    }
}
