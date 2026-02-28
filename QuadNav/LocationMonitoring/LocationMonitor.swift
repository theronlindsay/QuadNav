//
//  LocationMonitor.swift
//  LocationMonitoring
//
//  Created by Theron on 2/26/26.
//

import Foundation
import CoreLocation
import Observation

/// Create a class for Location Monitoring
@Observable
final class LocationMonitor: NSObject, CLLocationManagerDelegate {
    //monitor gets assigned when location monitoring is started
    private var monitor: CLMonitor?
    private var eventsTask: Task<Void, Never>?
    private var updateTask: Task<Void, Never>?
    private let locationManager = CLLocationManager()
    
    @MainActor var userLocation: CLLocation?
    @MainActor var isUserInQuad: Bool = false
    
    // Static center for the "Quad" condition
    let center = CLLocationCoordinate2D(latitude: 43.60437434240585, longitude: -116.20434424771985)
    //this radius variable is connected to a slider that defaults to 100 meters
    var radius: Double = 100 {
        didSet {
            updateTask?.cancel()
            updateTask = Task {
                await updateMonitorCondition()
            }
        }
    }

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    deinit {
        eventsTask?.cancel()
        updateTask?.cancel()
    }

    /// Updates the CLMonitor condition with the current radius.
    func updateMonitorCondition() async {
        //safely get the location monitor
        guard let monitor = self.monitor else { return }
        //set the center and radius
        let quadCondition = CLMonitor.CircularGeographicCondition(center: center, radius: radius)
        //updates the state of the Quad condidtion to the desired radius
        await monitor.add(quadCondition, identifier: "Quad")
    }

    /// Starts monitoring using a shared monitor name and listens for events.
    func startLocationMonitoring() async {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Create or access a named monitor. Using the same name elsewhere accesses the same monitor.
        self.monitor = await CLMonitor("iHeartMonitor")
        
        // Initial condition setup
        await updateMonitorCondition()
        
        // Receive and respond to updates
        
        //If eventsTask exists, cancel the task so duplicates aren't created
        eventsTask?.cancel()
        if let monitor = self.monitor {
            //Create a task to update location changes
            eventsTask = Task { [weak self] in
                guard let self else { return }
                do {
                    for try await event in await monitor.events {
                        // Ensure we are still active before taking action
                        if Task.isCancelled { break }
                        await self.takeAction(on: event)
                    }
                } catch {
                    #if DEBUG
                    print("LocationMonitor events stream error: \(error)")
                    #endif
                }
            }
        }
    }

    /// Stops monitoring and cancels the event stream task.
    func stop() {
        eventsTask?.cancel()
        eventsTask = nil
        updateTask?.cancel()
        updateTask = nil
        monitor = nil
        locationManager.stopUpdatingLocation()
    }
    
    /// Handle monitor events here.
    private func takeAction(on event: CLMonitor.Event) async {
        let identifier = event.identifier
        let state = event.state
        
        await MainActor.run {
            if identifier == "Quad" {
                switch state {
                case .satisfied:
                    isUserInQuad = true
                case .unsatisfied:
                    isUserInQuad = false
                case .unknown:
                    break
                @unknown default:
                    break
                }
            }
        }
        
        #if DEBUG
        print("Received monitor event: \(event)")
        #endif
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last
        Task { @MainActor in
            userLocation = lastLocation
        }
    }
}

