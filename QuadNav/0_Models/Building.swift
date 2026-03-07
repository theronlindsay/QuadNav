import Foundation
import CoreLocation

struct Building: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    
    // Equatable and Hashable are required for UI selection components like Pickers
    static func == (lhs: Building, rhs: Building) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Building {
    static let campusBuildings: [Building] = [
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
