//
//  LocationManager.swift
//  QuadNav
//
//  Created by Brandon Williams on 2/25/26.
//

import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject,
                             ObservableObject,
                             CLLocationManagerDelegate {
    
    // MARK: - Core Location Manager
    
    private let manager = CLLocationManager()
    
    // MARK: - Published State
    
    @Published var location: CLLocation?
    @Published var heading: CLHeading?
    @Published var authorizationStatus: CLAuthorizationStatus?
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        manager.delegate = self
        configureManager()
    }
    
    // MARK: - Configuration (Efficient Monitoring)
    
    private func configureManager() {
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.distanceFilter = 5
        manager.pausesLocationUpdatesAutomatically = true
        manager.activityType = .otherNavigation
    }
    
    // MARK: - Permission
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Start / Stop Updates
    
    func startUpdates() {
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
    }
    
    func stopUpdates() {
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdates()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateHeading newHeading: CLHeading) {
        
        if newHeading.headingAccuracy < 0 { return }
        
        heading = newHeading
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
}
