//
//  BearingCalculator.swift
//  QuadNav
//
//  Created by Brandon Williams on 2/25/26.
//
import CoreLocation
import Foundation

struct BearingCalculator {

    static func bearing(
        from start: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D
    ) -> Double {
        // Geographic bearing calculation
    }

    static func relativeAngle(
        userHeading: Double,
        targetBearing: Double
    ) -> Double {
        // Normalize angle between 0–360
    }

    static func distance(
        from userLocation: CLLocation,
        to buildingCoordinate: CLLocationCoordinate2D
    ) -> Double {
        let buildingLocation = CLLocation(
            latitude: buildingCoordinate.latitude,
            longitude: buildingCoordinate.longitude
        )
        return userLocation.distance(from: buildingLocation)
    }
}
