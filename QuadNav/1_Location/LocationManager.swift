//
//  LocationManager.swift
//  QuadNav
//
//  Created by Brandon Williams on 2/25/26.
//

import CoreLocation
import Combine

final class LocationManager: NSObject,
                             ObservableObject,
                             CLLocationManagerDelegate {

    private let manager = CLLocationManager()

    @Published var location: CLLocation?
    @Published var heading: CLHeading?
    @Published var authorizationStatus: CLAuthorizationStatus?

    override init() {
        super.init()
        manager.delegate = self
        configureManager()
    }

    private func configureManager() {
        // Efficient Monitoring Configuration
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.distanceFilter = 5
        manager.pausesLocationUpdatesAutomatically = true
        manager.activityType = .otherNavigation
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdates() {
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
    }

    func stopUpdates() {
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
    }

    // Delegate methods implemented here
}
