//
// BearingCalculator.swift
// Created by Brandon Williams & Amber
//

import Foundation
import CoreLocation

// MARK: - Bearing and Distance Calculator
// This struct provides utility functions for calculating:
// 1. The compass direction (bearing) from one location to another
// 2. The straight-line distance between two GPS coordinates
struct BearingCalculator {
    
    // MARK: - Bearing Calculation
    /// Calculates the compass direction from start to end coordinates in degrees
    /// - Parameters:
    ///   - start: Starting location
    ///   - end: Destination location
    /// - Returns: Compass angle in degrees (0–360°)
    static func bearing(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> Double {
        
        // Convert degrees to radians because Swift's trig functions use radians
        let startLatitude = start.latitude.degreesToRadians
        let startLongitude = start.longitude.degreesToRadians
        let endLatitude = end.latitude.degreesToRadians
        let endLongitude = end.longitude.degreesToRadians
        
        // Difference in longitude
        let deltaLongitude = endLongitude - startLongitude
        
        // Spherical trigonometry formula for initial bearing
        let y = sin(deltaLongitude) * cos(endLatitude)
        let x = cos(startLatitude) * sin(endLatitude) -
                sin(startLatitude) * cos(endLatitude) * cos(deltaLongitude)
        
        // atan2 returns the angle of the vector from x and y
        let radiansBearing = atan2(y, x)
        
        // Convert radians back to degrees
        let degreesBearing = radiansBearing.radiansToDegrees
        
        // Normalize to 0–360°
        return normalize(degreesBearing)
    }
    
    // MARK: - Distance Calculation
    /// Returns the straight-line distance in meters between the user and a target coordinate
    static func distance(from userLocation: CLLocation, to targetCoordinate: CLLocationCoordinate2D) -> Double {
        
        // Convert target coordinates to CLLocation for easy distance calculation
        let targetLocation = CLLocation(
            latitude: targetCoordinate.latitude,
            longitude: targetCoordinate.longitude
        )
        
        // distance(from:) returns distance in meters
        return userLocation.distance(from: targetLocation)
    }
    
    // MARK: - Angle Normalization
    /// Converts any angle to a valid compass heading between 0–360°
    private static func normalize(_ degrees: Double) -> Double {
        var normalized = degrees.truncatingRemainder(dividingBy: 360)
        if normalized < 0 { normalized += 360 }
        return normalized
    }
}

// MARK: - Double Extensions for Math
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
