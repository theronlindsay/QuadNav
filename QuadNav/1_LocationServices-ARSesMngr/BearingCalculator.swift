//
// BearingCalculator.swift
// Created by Brandon Williams & Amber
//

import Foundation
import CoreLocation

// Utility for geographic bearing and distance calculations
struct BearingCalculator {
    
    // MARK: - Bearing
    
    /// Returns compass bearing (0°–360°) from one coordinate to another
    static func bearing(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> Double {
        
        // Convert coordinates to radians
        let startLatitude = start.latitude.degreesToRadians
        let startLongitude = start.longitude.degreesToRadians
        let endLatitude = end.latitude.degreesToRadians
        let endLongitude = end.longitude.degreesToRadians
        
        // Longitude delta
        let deltaLongitude = endLongitude - startLongitude
        
        // Direction vector components
        let y = sin(deltaLongitude) * cos(endLatitude)
        
        let x = cos(startLatitude) * sin(endLatitude) -
                sin(startLatitude) * cos(endLatitude) * cos(deltaLongitude)
        
        // Angle in radians
        let radiansBearing = atan2(y, x)
        
        // Convert to degrees
        let degreesBearing = radiansBearing.radiansToDegrees
        
        // Normalize to 0–360°
        return normalize(degreesBearing)
    }
    
    
    // MARK: - Distance
    
    /// Returns distance in meters between a user location and a target coordinate
    static func distance(from userLocation: CLLocation, to targetCoordinate: CLLocationCoordinate2D) -> Double {
        
        let targetLocation = CLLocation(
            latitude: targetCoordinate.latitude,
            longitude: targetCoordinate.longitude
        )
        
        return userLocation.distance(from: targetLocation)
    }
    
    
    // MARK: - Helpers
    
    /// Ensures an angle remains within the 0–360° range
    private static func normalize(_ degrees: Double) -> Double {
        
        var normalized = degrees.truncatingRemainder(dividingBy: 360)
        
        if normalized < 0 { normalized += 360 }
        
        return normalized
    }
}


// MARK: - Double Angle Helpers

private extension Double {
    
    /// Converts degrees to radians
    var degreesToRadians: Double {
        self * .pi / 180
    }
    
    /// Converts radians to degrees
    var radiansToDegrees: Double {
        self * 180 / .pi
    }
}
