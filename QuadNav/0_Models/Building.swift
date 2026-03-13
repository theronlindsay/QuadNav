//
// Building.swift
// Created by Brandon Williams
//

import Foundation   // Provides basic Swift types like String, Array, UUID, and data utilities
import CoreLocation // Provides types to work with GPS coordinates and locations

// MARK: - Building Model
// This struct represents a building on campus. We store basic information like name and location.
struct Building: Identifiable, Equatable, Hashable {
    
    // MARK: Properties
    
    // Unique ID for each building. Used to compare or identify objects.
    let id = UUID()
    
    // The name of the building, e.g., "Library"
    let name: String
    
    // The GPS coordinates of the building
    let coordinate: CLLocationCoordinate2D
    
    // MARK: Equatable Protocol
    // Allows Swift to compare two Building objects to see if they are the same.
    static func == (lhs: Building, rhs: Building) -> Bool {
        lhs.id == rhs.id // Two buildings are considered equal if their IDs match
    }
    
    // MARK: Hashable Protocol
    // Hashable allows a Building to be stored in a Set or used as a Dictionary key.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id) // Use the unique ID for hashing
    }
}

// MARK: - Sample Data
// Adding a convenient list of sample buildings for testing and UI previews
extension Building {
    
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
