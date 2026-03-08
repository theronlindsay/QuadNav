//Created By Theron

import Foundation
// Provides core Swift functionality such as data types, math utilities,
// and base classes used across most Swift applications.

import CoreLocation
// Apple's framework for working with location services, GPS data,
// compass heading, and geographic calculations.

import Observation
// Apple's modern state observation framework used by SwiftUI.
// The @Observable macro allows UI elements to automatically update
// when properties in this class change.



// @Observable automatically generates change notifications
// so UI components observing this object refresh when values update.
@Observable

// final prevents other classes from inheriting from this class.
// This can improve performance and prevents unintended subclassing.
final class LocationMonitor: NSObject, CLLocationManagerDelegate {

    
    // MARK: - Geofence Monitoring Objects
    
    // CLMonitor manages geographic conditions (like regions or circular areas).
    // It triggers events when the user enters or exits a monitored area.
    private var monitor: CLMonitor?
    
    // Task used to listen for events from the CLMonitor.
    // Swift Concurrency uses Tasks for asynchronous work.
    private var eventsTask: Task<Void, Never>?
    
    // Task used when updating monitoring conditions.
    // Allows async work to run without blocking the UI.
    private var updateTask: Task<Void, Never>?
    
    
    
    // MARK: - Observed State
    
    
    // Stores the user's most recent GPS location.
    // @MainActor ensures this property is updated on the main thread,
    // which is required when UI may read this value.
    @MainActor var userLocation: CLLocation?
    
    
    // Boolean flag that indicates whether the user is inside the monitored area.
    // Default value is false until a location check occurs.
    @MainActor var isUserInQuad: Bool = false
    
    
    
    // MARK: - Quad Location Definition
    
    
    // The geographic center of the monitored area.
    // This coordinate represents the center point of the quad.
    let center = CLLocationCoordinate2D(
        latitude: 43.60437434240585,
        longitude: -116.20434424771985
    )
    
    
    // Radius of the monitored circular area (in meters).
    // didSet runs automatically whenever the radius value changes.
    var radius: Double = 100 {
        didSet {
            
            // Cancel any existing update task to avoid duplicates.
            updateTask?.cancel()
            
            // Start a new asynchronous task to update the monitored region.
            updateTask = Task {
                await updateMonitorCondition()
            }
            
            // Immediately re-check the user's distance relative to the quad.
            checkDistanceToQuad()
        }
    }
    
    
    
    // MARK: - Core Location Manager
    
    
    // Standard location manager used to receive GPS updates.
    private let locationManager = CLLocationManager()



    // MARK: - Initialization
    
    // init runs when this class instance is created.
    override init() {
        super.init()
        
        // Assign this class as the delegate to receive location updates.
        locationManager.delegate = self
        
        // Set the desired location accuracy.
        // This requests the most precise GPS reading available.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    
    // MARK: - Cleanup
    
    // deinit runs when the object is removed from memory.
    // Cancel running tasks to prevent background activity.
    deinit {
        eventsTask?.cancel()
        updateTask?.cancel()
    }

    
    
    // MARK: - Distance Check
    
    // Determines if the user is inside the quad radius.
    @MainActor
    private func checkDistanceToQuad() {
        
        // If we don't yet know the user's location, stop.
        guard let userLocation else { return }
        
        // Create a CLLocation object representing the quad center.
        let centerLocation = CLLocation(
            latitude: center.latitude,
            longitude: center.longitude
        )
        
        // Calculate distance from user to the quad center.
        let distance = userLocation.distance(from: centerLocation)
        
        // Update the boolean depending on whether the user
        // is inside the radius.
        isUserInQuad = distance <= radius
    }

    
    
    // MARK: - Update Geofence Condition
    
    // Updates the monitored circular region.
    func updateMonitorCondition() async {
        
        // If the monitor has not yet been created, exit early.
        guard let monitor = self.monitor else { return }
        
        // Create a circular geographic condition.
        // This defines the monitored area.
        let quadCondition = CLMonitor.CircularGeographicCondition(
            center: center,
            radius: radius
        )
        
        // Add this condition to the monitor.
        await monitor.add(quadCondition, identifier: "Quad")
    }

    
    
    // MARK: - Authorization Handling
    
    // Requests permission to access location if needed.
    private func requestAuthorizationIfNeeded() {
        
        // If the user has not yet been asked for permission
        if locationManager.authorizationStatus == .notDetermined {
            
            // Ask for location permission while the app is in use.
            locationManager.requestWhenInUseAuthorization()
            
        } else {
            
            // If permission already exists, start receiving location updates.
            locationManager.startUpdatingLocation()
        }
    }

    
    
    // MARK: - Start Monitoring
    
    // Begins location monitoring and geofence event listening.
    func startLocationMonitoring() async {
        
        // Ensure permission is granted.
        requestAuthorizationIfNeeded()
        
        // Create a new CLMonitor instance.
        self.monitor = await CLMonitor("QuadRadiusMonitor")
        
        // Add the quad region condition.
        await updateMonitorCondition()
        
        
        // Cancel any existing event listener task.
        eventsTask?.cancel()
        
        
        // Create a new task to listen for region events.
        eventsTask = Task { [weak self] in
            
            // Prevent strong reference cycles.
            guard let self, let monitor = self.monitor else { return }
            
            // Listen asynchronously for monitor events.
            do {
                for try await event in await monitor.events {
                    
                    // If the task has been cancelled, exit the loop.
                    if Task.isCancelled { break }
                    
                    // Process the event.
                    await self.takeAction(on: event)
                }
            } catch {
                // Handle potential monitor errors.
                print("CLMonitor error: \(error)")
            }
        }
    }

    
    
    // MARK: - Stop Monitoring
    
    // Stops monitoring and location updates.
    func stop() {
        eventsTask?.cancel()
        locationManager.stopUpdatingLocation()
    }

    
    
    // MARK: - Event Handling
    
    // Responds to geofence entry/exit events.
    private func takeAction(on event: CLMonitor.Event) async {
        
        await MainActor.run {
            
            // Check if the event corresponds to the quad region.
            if event.identifier == "Quad" {
                
                // Update the boolean based on the region state.
                self.isUserInQuad = (event.state == .satisfied)
            }
        }
    }

    
    
    // MARK: - CLLocationManagerDelegate
    
    
    // Called whenever the device receives updated GPS coordinates.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Retrieve the newest location from the array.
        if let lastLocation = locations.last {
            
            // Switch to the main thread to update UI-related state.
            Task { @MainActor in
                
                // Save the user location.
                self.userLocation = lastLocation
                
                // Re-check whether the user is inside the quad.
                self.checkDistanceToQuad()
            }
        }
    }
}
