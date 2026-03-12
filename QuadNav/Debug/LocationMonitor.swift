//
// LocationMonitor.swift
// Created by Brandon Williams & Amber
//

import Foundation
import CoreLocation
import Observation
import UserNotifications

// MARK: - Location & Geofence Manager
@Observable
final class LocationMonitor: NSObject, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {

    // MARK: Geofence Monitor
    
    private var monitor: CLMonitor?
    private var eventsTask: Task<Void, Never>?
    private var updateTask: Task<Void, Never>?

    // MARK: Observed State
    
    var userLocation: CLLocation?
    var isUserInQuad: Bool = false

    // MARK: Quad Definition
    
    let center = CLLocationCoordinate2D(
        latitude: 43.60437434240585,
        longitude: -116.20434424771985
    )

    var radius: Double = 100 {
        didSet {
            updateTask?.cancel()
            updateTask = Task { await updateMonitorCondition() }
            checkDistanceToQuad()
            registerGeofenceNotification()
        }
    }

    // MARK: Start / Stop Monitoring
    
    func startLocationMonitoring() async {
        requestAuthorizationIfNeeded()
        requestNotificationPermission()
        registerGeofenceNotification()
        
        if monitor == nil {
            monitor = await CLMonitor("QuadRadiusMonitor")
        }

        await updateMonitorCondition()
        
        eventsTask?.cancel()
        eventsTask = Task { [weak self] in
            guard let self, let monitor else { return }
            do {
                for try await event in await monitor.events {
                    if Task.isCancelled { break }
                    await handleEvent(event)
                }
            } catch {
                print("Monitor event error:", error)
            }
        }
    }

    func stop() {
        eventsTask?.cancel()
        updateTask?.cancel()
        eventsTask = nil
        updateTask = nil
        monitor = nil
        locationManager.stopUpdatingLocation()
    }

    // MARK: External Location Update
    
    func updateUserLocation(_ location: CLLocation) {
        userLocation = location
        checkDistanceToQuad()
    }
    
    private let locationManager = CLLocationManager()

    // MARK: Initialization
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        UNUserNotificationCenter.current().delegate = self
    }
    
    deinit {
        eventsTask?.cancel()
        updateTask?.cancel()
    }

    // MARK: Distance Check
    
    private func checkDistanceToQuad() {
        guard let userLocation else { return }
        let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        let distance = userLocation.distance(from: centerLocation)
        isUserInQuad = distance <= radius
    }

    // MARK: Notifications
    
    private func sendImmediateNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "quadImmediate-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            #if DEBUG
            if let error { print("Failed to send notification: \(error)") }
            #endif
        }
    }

    private func requestAuthorizationIfNeeded() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            #if DEBUG
            print("Location access denied or restricted.")
            #endif
        @unknown default: break
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            #if DEBUG
            if let error { print("Notification permission error: \(error)") }
            else { print("Notification permission granted: \(granted)") }
            #endif
        }
    }

    func registerGeofenceNotification() {
        // Remove previous notifications
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["quadGeofenceEntry", "quadGeofenceExit"])
        
        // Entry notification
        let entryContent = UNMutableNotificationContent()
        entryContent.title = "You've entered the Quad!"
        entryContent.body = "Welcome to Campus! You're now in the Quad area."
        entryContent.sound = .default
        
        let entryRegion = CLCircularRegion(center: center, radius: radius, identifier: "quadEntryRegion")
        entryRegion.notifyOnEntry = true
        entryRegion.notifyOnExit = false
        let entryTrigger = UNLocationNotificationTrigger(region: entryRegion, repeats: true)
        let entryRequest = UNNotificationRequest(identifier: "quadGeofenceEntry", content: entryContent, trigger: entryTrigger)
        UNUserNotificationCenter.current().add(entryRequest) { error in
            #if DEBUG
            if let error { print("Failed to register entry notification: \(error)") }
            else { print("Entry geofence notification registered with radius: \(entryRegion.radius)m") }
            #endif
        }
        
        // Exit notification
        let exitContent = UNMutableNotificationContent()
        exitContent.title = "You've left the Quad"
        exitContent.body = "You'll be back soon!"
        exitContent.sound = .default
        
        let exitRegion = CLCircularRegion(center: center, radius: radius, identifier: "quadExitRegion")
        exitRegion.notifyOnEntry = false
        exitRegion.notifyOnExit = true
        let exitTrigger = UNLocationNotificationTrigger(region: exitRegion, repeats: true)
        let exitRequest = UNNotificationRequest(identifier: "quadGeofenceExit", content: exitContent, trigger: exitTrigger)
        UNUserNotificationCenter.current().add(exitRequest) { error in
            #if DEBUG
            if let error { print("Failed to register exit notification: \(error)") }
            else { print("Exit geofence notification registered with radius: \(exitRegion.radius)m") }
            #endif
        }
    }

    // MARK: Monitor Updates
    
    func updateMonitorCondition() async {
        guard let monitor else { return }
        let quadCondition = CLMonitor.CircularGeographicCondition(center: center, radius: radius)
        await monitor.add(quadCondition, identifier: "Quad")
    }

    private func handleEvent(_ event: CLMonitor.Event) async {
        guard event.identifier == "Quad" else { return }
        await MainActor.run {
            let wasInQuad = isUserInQuad
            switch event.state {
            case .satisfied: isUserInQuad = true
            case .unsatisfied: isUserInQuad = false
            default: break
            }
            if isUserInQuad && !wasInQuad {
                sendImmediateNotification(title: "You're in the Quad!", body: "You have entered the Quad area.")
            } else if !isUserInQuad && wasInQuad {
                sendImmediateNotification(title: "You've left the Quad", body: "You have exited the Quad area.")
            }
        }
    }

    // MARK: CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        requestAuthorizationIfNeeded()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        updateUserLocation(lastLocation)
    }

    // MARK: UNUserNotificationCenterDelegate
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
