import Foundation
import CoreLocation
import Observation

@Observable
class NavigationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    var userLocation: CLLocation?
    var userHeading: CLHeading?
    var selectedBuilding: Building?
    
    var distanceToTarget: Double {
        guard let userLocation, let selectedBuilding else { return 0 }
        return BearingCalculator.distance(from: userLocation, to: selectedBuilding.coordinate)
    }
    
    var targetBearing: Double {
        guard let userLocation, let selectedBuilding else { return 0 }
        return BearingCalculator.bearing(from: userLocation.coordinate, to: selectedBuilding.coordinate)
    }

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        userHeading = newHeading
    }
}
