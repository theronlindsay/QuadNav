//
// Building.swift
// Created by BrandonWilliams & AmberTaggart
//

import Foundation
import CoreLocation

// Represents a campus building with a name and map coordinate
struct Building: Identifiable, Equatable, Hashable {
    
    // MARK: - Properties
    
    let id = UUID() // Unique identifier
    let name: String
    let coordinate: CLLocationCoordinate2D
    
    // MARK: - Equatable
    
    static func == (lhs: Building, rhs: Building) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Sample Data

extension Building {
    
    // Demo list of campus buildings
    static let campusBuildings: [Building] = [
        
        Building(
            name: "Riverfront Hall",
            coordinate: CLLocationCoordinate2D(latitude: 43.60490586285641, longitude: -116.20471633098414)
        ),
        Building(
            name: "Library",
            coordinate: CLLocationCoordinate2D(latitude: 43.60426249533757, longitude: -116.20323924845822)
        ),
        Building(
            name: "Student Union",
            coordinate: CLLocationCoordinate2D(latitude: 43.60176162233832, longitude: -116.2017352425342)
        ),
        Building(
            name: "Administration Building",
            coordinate: CLLocationCoordinate2D(latitude: 43.603688341185745, longitude: -116.20469907947239)
        ),
        Building(
            name: "BSU Quad",
            coordinate: CLLocationCoordinate2D(latitude: 43.604060421704716, longitude: -116.20438537881842)
        ),
        Building(
            name: "Math Building",
            coordinate: CLLocationCoordinate2D(latitude: 43.604419492939876, longitude: -116.20568863212578)
        )
    ]
}
