//
//  Building.swift
//  QuadNav
//
//  Created by Brandon Williams on 2/25/26.
//

import Foundation
import CoreLocation

struct Building {
    let name: String
    let coordinate: CLLocationCoordinate2D
}
extension Building {
    static let campusBuildings: [Building] = [
        Building(name: "Building A",
                 coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)),
        Building(name: "Building B",
                 coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)),
        Building(name: "Building C",
                 coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)),
        Building(name: "Building D",
                 coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
    ]
}
