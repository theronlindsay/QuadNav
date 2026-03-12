//
// NavigationManager.swift
// Created by Brandon Williams & Amber
//

import Foundation
import CoreLocation
import Observation

@Observable
class NavigationManager: NSObject, CLLocationManagerDelegate {
    
    
    // MARK: - Location Manager
    
    private let manager = CLLocationManager()
    
    
    // MARK: - State
    
    var userLocation: CLLocation?
    
    var locationMonitor = LocationMonitor()
    
    var userHeading: CLHeading?
    
    var selectedBuilding: Building?
    
    private var filteredHeading: Double?
    
    /// Smoothed compass heading for UI use (degrees)
    var filteredHeadingForUI: Double? { filteredHeading }
    
    
    // MARK: - Computed Navigation Data
    
    /// Distance from user to selected building (meters)
    var distanceToTarget: Double {
        
        guard let userLocation, let selectedBuilding else { return 0 }
        
        return BearingCalculator.distance(
            from: userLocation,
            to: selectedBuilding.coordinate
        )
    }
    
    
    /// Compass bearing from user to selected building
    var targetBearing: Double {
        
        guard let userLocation, let selectedBuilding else { return 0 }
        
        return BearingCalculator.bearing(
            from: userLocation.coordinate,
            to: selectedBuilding.coordinate
        )
    }
    
    
    /// Angle difference between device heading and target bearing
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
        
        while difference > 180 { difference -= 360 }
        while difference < -180 { difference += 360 }
        
        return difference
    }
    
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        
        manager.delegate = self
        
        // Navigation-grade accuracy
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        manager.headingFilter = 1
        
        manager.requestWhenInUseAuthorization()
        
        manager.startUpdatingLocation()
        
        manager.startUpdatingHeading()
    }
    
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }
        
        userLocation = location
        
        locationMonitor.updateUserLocation(location)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        // Ignore poor compass readings
        guard newHeading.headingAccuracy >= 0,
              newHeading.headingAccuracy <= 20 else { return }
        
        let rawHeading =
            newHeading.trueHeading >= 0
            ? newHeading.trueHeading
            : newHeading.magneticHeading
        
        // Smooth heading to reduce jitter
        if let previous = filteredHeading {
            let smoothingFactor = 0.15
            filteredHeading = previous + smoothingFactor * (rawHeading - previous)
        } else {
            filteredHeading = rawHeading
        }
        
        userHeading = newHeading
    }
    
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
}
