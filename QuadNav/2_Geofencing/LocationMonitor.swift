import Foundation
import CoreLocation
import Observation

@Observable
final class LocationMonitor: NSObject, CLLocationManagerDelegate {
    private var monitor: CLMonitor?
    private var eventsTask: Task<Void, Never>?
    private var updateTask: Task<Void, Never>?
    
    @MainActor var userLocation: CLLocation?
    @MainActor var isUserInQuad: Bool = false
    
    let center = CLLocationCoordinate2D(latitude: 43.60437434240585, longitude: -116.20434424771985)
    
    var radius: Double = 100 {
        didSet {
            updateTask?.cancel()
            updateTask = Task { await updateMonitorCondition() }
            checkDistanceToQuad()
        }
    }

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    deinit {
        eventsTask?.cancel()
        updateTask?.cancel()
    }

    @MainActor
    private func checkDistanceToQuad() {
        guard let userLocation else { return }
        let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        let distance = userLocation.distance(from: centerLocation)
        isUserInQuad = distance <= radius
    }

    func updateMonitorCondition() async {
        guard let monitor = self.monitor else { return }
        let quadCondition = CLMonitor.CircularGeographicCondition(center: center, radius: radius)
        await monitor.add(quadCondition, identifier: "Quad")
    }

    private func requestAuthorizationIfNeeded() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.startUpdatingLocation()
        }
    }

    func startLocationMonitoring() async {
        requestAuthorizationIfNeeded()
        self.monitor = await CLMonitor("QuadRadiusMonitor")
        await updateMonitorCondition()
        
        eventsTask?.cancel()
        eventsTask = Task { [weak self] in
            guard let self, let monitor = self.monitor else { return }
            // Corrected: Handled potential error to satisfy Task<Void, Never>
            do {
                for try await event in await monitor.events {
                    if Task.isCancelled { break }
                    await self.takeAction(on: event)
                }
            } catch {
                print("CLMonitor error: \(error)")
            }
        }
    }

    func stop() {
        eventsTask?.cancel()
        locationManager.stopUpdatingLocation()
    }

    private func takeAction(on event: CLMonitor.Event) async {
        await MainActor.run {
            if event.identifier == "Quad" {
                self.isUserInQuad = (event.state == .satisfied)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            Task { @MainActor in
                self.userLocation = lastLocation
                self.checkDistanceToQuad()
            }
        }
    }
}
