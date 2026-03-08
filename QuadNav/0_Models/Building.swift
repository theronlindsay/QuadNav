// Created by BrandonWilliams


import Foundation   // Provides basic data types, structures, and utilities for Swift
import CoreLocation // Provides classes for working with locations, coordinates, and GPS

// Define a structure called "Building"
// A struct is like a lightweight class: it holds related data together
// Here, a Building has an id, a name, and coordinates
struct Building: Identifiable, Equatable, Hashable {
    
    // MARK: - Properties
    
    let id = UUID() // A unique identifier for this building (UUID = universally unique identifier)
    let name: String // The name of the building (e.g., "Library")
    let coordinate: CLLocationCoordinate2D // The GPS coordinates (latitude & longitude)
    
    // MARK: - Equatable Protocol
    // Equatable allows Swift to check if two Building instances are the same
    // Needed for things like lists, pickers, or comparisons
    static func == (lhs: Building, rhs: Building) -> Bool {
        lhs.id == rhs.id // Two buildings are equal if their IDs match
    }
    
    // MARK: - Hashable Protocol
    // Hashable allows Building to be stored in sets or used as dictionary keys
    // Hashing converts the object into a number for efficient lookup
    func hash(into hasher: inout Hasher) {
        hasher.combine(id) // Use the unique ID for hashing
    }
}

// MARK: - Extension for sample data
// Extensions in Swift allow us to add extra functionality to structs or classes
extension Building {
    
    // A static property is shared by all Building instances
    // Here, it’s a list of some buildings on campus for demonstration
    static let campusBuildings: [Building] = [
        
        // Each item here is an instance of Building
        Building(
            name: "GIMM Lab",
            coordinate: CLLocationCoordinate2D(latitude: 43.6025, longitude: -116.2034)
        ),
        Building(
            name: "Library",
            coordinate: CLLocationCoordinate2D(latitude: 43.6028, longitude: -116.2040)
        ),
        Building(
            name: "Student Union",
            coordinate: CLLocationCoordinate2D(latitude: 43.6032, longitude: -116.2037)
        ),
        Building(
            name: "Science Building",
            coordinate: CLLocationCoordinate2D(latitude: 43.6029, longitude: -116.2028)
        )
    ]
}
