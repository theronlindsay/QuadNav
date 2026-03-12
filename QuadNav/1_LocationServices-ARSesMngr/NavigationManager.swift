//Created by Brandon Williams & Amber

import Foundation
// Provides core Swift functionality such as data types, utilities,
// and base classes used across most Swift programs.

import CoreLocation
// Apple framework used for working with GPS data, device location,
// compass heading, and geographic calculations.

import Observation
// Observation is part of Apple's modern state-tracking system.
// The @Observable macro allows SwiftUI or other UI layers to
// automatically update when properties change.

@Observable

class NavigationManager: NSObject, CLLocationManagerDelegate {
    
    
    // MARK: - Core Location Manager
    
    private let manager = CLLocationManager()
    
    
    
    
    // MARK: - Stored State
    
    var userLocation: CLLocation?
    
    var locationMonitor = LocationMonitor()
    
    var userHeading: CLHeading?
    
    var selectedBuilding: Building?
    
    private var filteredHeading: Double?

    /// Read-only accessor for UI layers. Returns the smoothed compass heading in degrees.
    var filteredHeadingForUI: Double? { filteredHeading }
    
    
    // MARK: - Computed Properties
    
    var distanceToTarget: Double {
        
        guard let userLocation, let selectedBuilding else { return 0 }
        
        return BearingCalculator.distance(
            from: userLocation,
            to: selectedBuilding.coordinate
        )
    }
    
    
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
        
        // Changed to navigation grade accuracy
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        manager.headingFilter = 1
        
        manager.requestWhenInUseAuthorization()
        
        manager.startUpdatingLocation()
        
        manager.startUpdatingHeading()
    }
    
    
    // MARK: - CLLocationManagerDelegate Methods
    
    
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
    
    
    
}

