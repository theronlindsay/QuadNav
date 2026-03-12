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


// @Observable automatically generates code so that when any
// stored property changes, the UI observing this object updates.
// This replaces older approaches like ObservableObject + @Published.
@Observable

// A class is used instead of a struct because we need reference
// behavior and integration with Apple's delegate system.
class NavigationManager: NSObject, CLLocationManagerDelegate {
    
    
    // MARK: - Core Location Manager
    
    // CLLocationManager is the Apple object responsible for:
    // • requesting GPS data
    // • requesting compass data
    // • managing permissions
    private let manager = CLLocationManager()
    
    
    // MARK: - Stored State
    
    // The device’s most recent GPS location.
    // Optional (?) because the location might not be known yet.
    var userLocation: CLLocation?
    
    var locationMonitor = LocationMonitor()
    
    // The device’s compass heading (direction the phone is facing).
    // Also optional because it may not be available immediately.
    var userHeading: CLHeading?
    
    // The building the user has selected as a navigation target.
    // This uses your custom Building struct from another file.
    var selectedBuilding: Building?
    
    
    // MARK: - Computed Properties
    
    
    // Calculates the distance from the user to the selected building.
    // Computed properties run code whenever they are accessed.
    var distanceToTarget: Double {
        
        // "guard let" safely unwraps optional values.
        // If userLocation OR selectedBuilding are nil,
        // the function immediately returns 0.
        guard let userLocation, let selectedBuilding else { return 0 }
        
        // Calls your helper utility to calculate the distance.
        return BearingCalculator.distance(
            from: userLocation,
            to: selectedBuilding.coordinate
        )
    }
    
    
    // Calculates the compass bearing from the user to the building.
    // The result is the direction the arrow should point.
    var targetBearing: Double {
        
        // Again ensure both values exist before calculating.
        guard let userLocation, let selectedBuilding else { return 0 }
        
        // Uses the math utility you wrote earlier.
        return BearingCalculator.bearing(
            from: userLocation.coordinate,
            to: selectedBuilding.coordinate
        )
    }

    
    // MARK: - Initialization
    
    // init() runs when a NavigationManager object is created.
    override init() {
        super.init()
        
        // Assign this object as the delegate of CLLocationManager.
        // Delegates receive updates such as new GPS data.
        manager.delegate = self
        
        // Sets the desired accuracy of location updates.
        // kCLLocationAccuracyBest uses the most precise GPS available.
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Requests permission from the user to access location
        // while the app is running.
        manager.requestWhenInUseAuthorization()
        
        // Starts continuous GPS updates.
        manager.startUpdatingLocation()
        
        // Starts compass updates (device heading).
        manager.startUpdatingHeading()
    }
    
    
    // MARK: - CLLocationManagerDelegate Methods
    
    
    // This delegate function is called whenever the device
    // receives new GPS location data.
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {

        guard let location = locations.last else { return }

        userLocation = location

        locationMonitor.updateUserLocation(location)
    }
    
    
    // This delegate function runs when the device's compass
    // heading changes.
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        // Save the newest heading measurement.
        userHeading = newHeading
    }
}
