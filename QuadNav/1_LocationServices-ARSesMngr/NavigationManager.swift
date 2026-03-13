//
// NavigationManager.swift
// Created by Brandon Williams & Amber
//

import Foundation
import CoreLocation
import Observation
// CoreLocation provides GPS, heading, and device location info
// Observation allows @Observable to automatically update SwiftUI views

// MARK: - Navigation Manager
// This class handles everything about the user's location, heading, and navigation toward a selected building.
// It smooths compass readings, calculates distances and bearings, and provides relative directions for AR or Map views.
@Observable
class NavigationManager: NSObject, CLLocationManagerDelegate {
    
    // MARK: - Core Location Manager
    private let manager = CLLocationManager() // Handles GPS updates and heading data
    
    // MARK: - Observed State
    var userLocation: CLLocation?             // Latest GPS location
    var locationMonitor = LocationMonitor()   // Tracks whether user is in Quad
    var userHeading: CLHeading?               // Latest compass heading
    
    var selectedBuilding: Building?           // The building user wants to navigate to
    private var filteredHeading: Double?      // Smoothed compass reading
    
    // Read-only version of smoothed heading for UI updates
    var filteredHeadingForUI: Double? { filteredHeading }
    
    // MARK: - Computed Properties
    
    /// Distance to the selected building in meters
    var distanceToTarget: Double {
        guard let userLocation, let selectedBuilding else { return 0 }
        return BearingCalculator.distance(
            from: userLocation,
            to: selectedBuilding.coordinate
        )
    }
    
    /// Absolute compass bearing toward the selected building (0°–360°)
    var targetBearing: Double {
        guard let userLocation, let selectedBuilding else { return 0 }
        return BearingCalculator.bearing(
            from: userLocation.coordinate,
            to: selectedBuilding.coordinate
        )
    }
    
    // MARK: - Initialization
    override init() {
        super.init()
        manager.delegate = self
        
        // Best accuracy for navigation (uses GPS + magnetometer)
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        // Filter out small heading changes (<1°)
        manager.headingFilter = 1
        
        // Ask user for location permission when app is in use
        manager.requestWhenInUseAuthorization()
        
        // Start receiving location and heading updates
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    // Called when device location changes
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }
        userLocation = location
        locationMonitor.updateUserLocation(location)
    }
    
    // Called when compass heading changes
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // Ignore poor readings
        guard newHeading.headingAccuracy >= 0, newHeading.headingAccuracy <= 20 else { return }
        
        // Use true heading if available, otherwise magnetic heading
        let rawHeading =
            newHeading.trueHeading >= 0
            ? newHeading.trueHeading
            : newHeading.magneticHeading
        
        // Smooth heading changes to reduce jitter
        if let previous = filteredHeading {
            let smoothingFactor = 0.15
            filteredHeading = previous + smoothingFactor * (rawHeading - previous)
        } else {
            filteredHeading = rawHeading
        }
        
        userHeading = newHeading
    }
    
    // Required by CLLocationManagerDelegate to show calibration
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    // MARK: - Relative Bearing
    /// Returns the difference (in degrees) between device heading and target building
    /// Positive = turn clockwise, Negative = turn counter-clockwise
    var relativeBearing: Double {
        guard let userLocation,
              let selectedBuilding,
              let deviceHeading = filteredHeading
        else { return 0 }
        
        let target = BearingCalculator.bearing(
            from: userLocation.coordinate,
            to: selectedBuilding.coordinate
        )
        
        var difference = target - deviceHeading
        
        // Normalize to -180° … +180° for easier turning
        while difference > 180 { difference -= 360 }
        while difference < -180 { difference += 360 }
        
        return difference
    }
}
