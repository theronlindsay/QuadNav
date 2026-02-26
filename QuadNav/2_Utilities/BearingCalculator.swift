//We figure out the direction from one location to another using globe-based math, convert that angle into normal compass degrees, adjust it to fit within 0–360°, then compare it to the direction the phone is currently facing so we can rotate the on-screen arrow to point the right way.

import Foundation
import CoreLocation

struct BearingCalculator {
    
    // MARK: - Calculate Initial Bearing Between Two Coordinates
    
    static func bearing(
        from start: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D
    ) -> Double {
        
        let startLatitude = start.latitude.degreesToRadians
        let startLongitude = start.longitude.degreesToRadians
        let endLatitude = end.latitude.degreesToRadians
        let endLongitude = end.longitude.degreesToRadians
        
        let deltaLongitude = endLongitude - startLongitude
        
        let y = sin(deltaLongitude) * cos(endLatitude)
        let x = cos(startLatitude) * sin(endLatitude) -
                sin(startLatitude) * cos(endLatitude) * cos(deltaLongitude)
        
        let radiansBearing = atan2(y, x)
        
        let degreesBearing = radiansBearing.radiansToDegrees
        
        return normalize(degreesBearing)
    }
    
    
    // MARK: - Calculate Relative Angle for Arrow Rotation
    
    static func relativeAngle(
        userHeading: Double,
        targetBearing: Double
    ) -> Double {
        
        let difference = targetBearing - userHeading
        return normalize(difference)
    }
    
    
    // MARK: - Distance Calculation
    
    static func distance(
        from userLocation: CLLocation,
        to targetCoordinate: CLLocationCoordinate2D
    ) -> Double {
        
        let targetLocation = CLLocation(
            latitude: targetCoordinate.latitude,
            longitude: targetCoordinate.longitude
        )
        
        return userLocation.distance(from: targetLocation)
    }
    
    
    // MARK: - Normalize Angle to 0...360
    
    private static func normalize(_ degrees: Double) -> Double {
        var normalized = degrees.truncatingRemainder(dividingBy: 360)
        if normalized < 0 {
            normalized += 360
        }
        return normalized
    }
}


// MARK: - Degree / Radian Conversion Extensions

private extension Double {
    
    var degreesToRadians: Double {
        return self * .pi / 180
    }
    
    var radiansToDegrees: Double {
        return self * 180 / .pi
    }
}
