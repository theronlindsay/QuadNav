//Created by Brandon Williams & Amber
// This file contains a utility that calculates:
// 1. The compass direction (bearing) from one location to another
// 2. The distance between two locations

import Foundation
// Foundation provides core Swift utilities like math functions, numbers, and base data types.

import CoreLocation
// CoreLocation is Apple’s framework for working with GPS, coordinates, compass data,
// and geographic calculations.


// A struct is a container for related functionality and data.
// Here we are grouping together location-based math functions
// related to direction and distance.
struct BearingCalculator {
    
    
    // MARK: - Bearing Calculation
    
    // This function calculates the compass direction from one coordinate to another.
    // Example: If the user is standing somewhere and wants to know
    // what direction another building is located.
    //
    // "static" means we don't need to create an instance of BearingCalculator
    // to use this function. We can call it directly like:
    // BearingCalculator.bearing(from:to:)
    
    static func bearing(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> Double {
        
        // Convert latitude and longitude from degrees into radians.
        // Most trigonometric math functions (sin, cos, atan2) expect radians.
        let startLatitude = start.latitude.degreesToRadians
        let startLongitude = start.longitude.degreesToRadians
        let endLatitude = end.latitude.degreesToRadians
        let endLongitude = end.longitude.degreesToRadians
        
        
        // Find the difference in longitude between the two points.
        // This is required for spherical direction calculations.
        let deltaLongitude = endLongitude - startLongitude
        
        
        // These formulas come from spherical trigonometry used in navigation.
        // They determine the directional vector between two points on a sphere (Earth).
        
        let y = sin(deltaLongitude) * cos(endLatitude)
        
        let x = cos(startLatitude) * sin(endLatitude) -
                sin(startLatitude) * cos(endLatitude) * cos(deltaLongitude)
        
        
        // atan2 determines the angle of the vector using x and y.
        // The result is returned in radians.
        let radiansBearing = atan2(y, x)
        
        
        // Convert the angle from radians back into degrees
        // because compass directions are expressed in degrees (0°–360°).
        let degreesBearing = radiansBearing.radiansToDegrees
        
        
        // Normalize ensures the result stays within the valid compass range.
        // Example: if the math produces -45°, it becomes 315°.
        return normalize(degreesBearing)
    }

    
    // MARK: - Distance Calculation
    
    // This function calculates the straight-line distance between the user's
    // current GPS location and a target coordinate.
    
    static func distance(from userLocation: CLLocation, to targetCoordinate: CLLocationCoordinate2D) -> Double {
        
        // Convert the target coordinate into a CLLocation object.
        // CLLocation provides built-in distance calculations.
        let targetLocation = CLLocation(
            latitude: targetCoordinate.latitude,
            longitude: targetCoordinate.longitude
        )
        
        // distance(from:) returns the distance in meters between two locations.
        return userLocation.distance(from: targetLocation)
    }
    
    
    // MARK: - Angle Normalization
    
    // This helper function ensures a compass angle stays within 0–360 degrees.
    // Compass headings should never be negative or exceed 360.
    
    private static func normalize(_ degrees: Double) -> Double {
        
        // truncatingRemainder keeps the value within a 360° cycle.
        // Example: 450° becomes 90°
        var normalized = degrees.truncatingRemainder(dividingBy: 360)
        
        // If the value is negative, wrap it around into the positive range.
        if normalized < 0 { normalized += 360 }
        
        return normalized
    }
}


// MARK: - Double Math Helpers

// Extensions allow us to add functionality to existing types.
// Here we extend the built-in Double type with conversion helpers.
private extension Double {
    
    // Converts degrees to radians.
    // Example: 180° becomes π radians.
    var degreesToRadians: Double {
        self * .pi / 180
    }
    
    // Converts radians back into degrees.
    // Example: π radians becomes 180°.
    var radiansToDegrees: Double {
        self * 180 / .pi
    }
}
