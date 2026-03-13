//
// LocationMonitor.swift
// Created by Brandon Williams & Amber
//

import Foundation
import CoreLocation
import Observation
import UserNotifications
// Foundation: core Swift types and utilities
// CoreLocation: access GPS coordinates and heading
// Observation: allows @Observable to automatically notify SwiftUI when values change
// UserNotifications: send local notifications when entering/exiting geofence

// MARK: - LocationMonitor
// Tracks the user's location, monitors whether they are inside a geofence (Quad),
// and sends notifications for entering/exiting that geofence.
@Observable
final class LocationMonitor: NSObject, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    
    // MARK: - Geofence Monitor
    private var monitor: CLMonitor?               // Async geofence monitor (checks if user is inside defined area)
    private var eventsTask: Task<Void, Never>?    // Task to listen for geofence events asynchronously
    private var updateTask: Task<Void, Never>?    // Task to update geofence settings when radius changes
    
    // MARK: - Observed State
    var userLocation: CLLocation?                // Latest GPS location
    var isUserInQuad: Bool = false               // True if user is inside the Quad geofence
    
    // MARK: - Quad Definition
    // Center coordinate of the Quad area
    let center = CLLocationCoordinate2D(
        latitude: 43.60437434240585,
        longitude: -116.20434424771985
    )
    
    // Radius of the Quad geofence in meters
    var radius: Double = 100 {
        didSet {
            // Whenever the radius changes, update geofence monitor and notifications
            updateTask?.cancel()
            updateTask = Task { await updateMonitorCondition() }
            
            checkDistanceToQuad()           // Recalculate whether the user is inside the Quad
            registerGeofenceNotification()  // Update entry/exit notifications
        }
    }
    
    // MARK: - Core Location Manager
    private let locationManager = CLLocationManager()
    
    // MARK: - Initialization
    override init() {
        super.init()
        locationManager.delegate = self            // Receive location updates
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        UNUserNotificationCenter.current().delegate = self // Handle notifications when app is in foreground
    }
    
    deinit {
        // Cancel any running tasks when this object is destroyed
        eventsTask?.cancel()
        updateTask?.cancel()
    }
    
    // MARK: - Start Monitoring
    /// Call to start location updates and geofence monitoring
    func startLocationMonitoring() async {
        requestAuthorizationIfNeeded()      // Ask for location permission if needed
        requestNotificationPermission()     // Ask for notification permission
        registerGeofenceNotification()      // Set up entry/exit notifications
        
        if monitor == nil {
            monitor = await CLMonitor("QuadRadiusMonitor") // Create asynchronous geofence monitor
        }
        
        await updateMonitorCondition() // Update geofence with current radius
        
        // Listen for geofence events
        eventsTask?.cancel()
        eventsTask = Task { [weak self] in
            guard let self, let monitor else { return }
            
            do {
                for try await event in await monitor.events {
                    if Task.isCancelled { break }
                    await handleEvent(event)  // Process entry/exit events
                }
            } catch {
                print("Monitor event error:", error)
            }
        }
    }
    
    // MARK: - Stop Monitoring
    /// Stops location and geofence monitoring
    func stop() {
        eventsTask?.cancel()
        updateTask?.cancel()
        eventsTask = nil
        updateTask = nil
        monitor = nil
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - Update User Location
    /// Called by NavigationManager whenever GPS updates
    func updateUserLocation(_ location: CLLocation) {
        userLocation = location
        checkDistanceToQuad() // Update isUserInQuad state
    }
    
    // MARK: - Distance Check
    /// Calculates distance from user to Quad center
    /// Updates isUserInQuad accordingly
    private func checkDistanceToQuad() {
        guard let userLocation else { return }
        let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        let distance = userLocation.distance(from: centerLocation)
        isUserInQuad = distance <= radius
    }
    
    // MARK: - Send Immediate Notification
    /// Shows a notification immediately (foreground or background)
    private func sendImmediateNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Trigger almost immediately
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
    
    // MARK: - Request Permissions
    /// Checks and requests location authorization
    private func requestAuthorizationIfNeeded() {
        let status = locationManager.authorizationStatus
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization() // Needed for background geofence updates
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            #if DEBUG
            print("Location access denied or restricted.")
            #endif
        @unknown default: break
        }
    }
    
    /// Requests notification permission for alerts and sounds
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            #if DEBUG
            if let error { print("Notification permission error: \(error)") }
            else { print("Notification permission granted: \(granted)") }
            #endif
        }
    }
    
    // MARK: - Geofence Notifications
    /// Registers entry and exit notifications for the Quad geofence
    func registerGeofenceNotification() {
        // Remove old notifications
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["quadGeofenceEntry", "quadGeofenceExit"]
        )
        
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
    
    // MARK: - Update Monitor Condition
    /// Updates the async geofence monitor with current radius
    func updateMonitorCondition() async {
        guard let monitor else { return }
        let quadCondition = CLMonitor.CircularGeographicCondition(center: center, radius: radius)
        await monitor.add(quadCondition, identifier: "Quad")
    }
    
    // MARK: - Handle Geofence Events
    /// Called whenever the user enters or exits the Quad
    private func handleEvent(_ event: CLMonitor.Event) async {
        guard event.identifier == "Quad" else { return }
        
        await MainActor.run {
            let wasInQuad = isUserInQuad
            
            switch event.state {
            case .satisfied:
                isUserInQuad = true
            case .unsatisfied:
                isUserInQuad = false
            default:
                break
            }
            
            // Trigger notifications only when state changes
            if isUserInQuad && !wasInQuad {
                sendImmediateNotification(title: "You're in the Quad!", body: "You have entered the Quad area.")
            } else if !isUserInQuad && wasInQuad {
                sendImmediateNotification(title: "You've left the Quad", body: "You have exited the Quad area.")
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        requestAuthorizationIfNeeded()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        updateUserLocation(lastLocation)
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    /// Ensures notifications show as banners with sound even when app is foregrounded
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
