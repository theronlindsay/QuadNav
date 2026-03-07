//  Building.swift
//  QuadNav
//
//  Created by Brandon Williams on 2/25/26.
//creates variable sturctured objects that can be refferenced

import Foundation
import CoreLocation

struct Building: Identifiable, Equatable {
    
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    
}


// MARK: - Static Campus Data

extension Building {
    
    static let campusBuildings: [Building] = [
        
        Building(
            name: "GIMM Lab",
            coordinate: CLLocationCoordinate2D(
                latitude: 43.6025,
                longitude: -116.2034
            )
        ),
        
        Building(
            name: "Library",
            coordinate: CLLocationCoordinate2D(
                latitude: 43.6028,
                longitude: -116.2040
            )
        ),
        
        Building(
            name: "Student Union",
            coordinate: CLLocationCoordinate2D(
                latitude: 43.6032,
                longitude: -116.2037
            )
        ),
        
        Building(
            name: "Science Building",
            coordinate: CLLocationCoordinate2D(
                latitude: 43.6029,
                longitude: -116.2028
            )
        )
    ]
}
