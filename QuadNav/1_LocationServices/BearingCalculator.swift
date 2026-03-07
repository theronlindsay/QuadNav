import Foundation
import CoreLocation

struct BearingCalculator {
    
    static func bearing(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> Double {
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

    static func distance(from userLocation: CLLocation, to targetCoordinate: CLLocationCoordinate2D) -> Double {
        let targetLocation = CLLocation(latitude: targetCoordinate.latitude, longitude: targetCoordinate.longitude)
        return userLocation.distance(from: targetLocation)
    }
    
    private static func normalize(_ degrees: Double) -> Double {
        var normalized = degrees.truncatingRemainder(dividingBy: 360)
        if normalized < 0 { normalized += 360 }
        return normalized
    }
}

private extension Double {
    var degreesToRadians: Double { self * .pi / 180 }
    var radiansToDegrees: Double { self * 180 / .pi }
}
