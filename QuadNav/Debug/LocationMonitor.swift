import Foundation
import CoreLocation
import Observation

@Observable
final class LocationMonitor {

    // MARK: - Geofence Monitor

    private var monitor: CLMonitor?
    private var eventsTask: Task<Void, Never>?
    private var updateTask: Task<Void, Never>?


    // MARK: - Observed State

    var userLocation: CLLocation?

    var isUserInQuad: Bool = false


    // MARK: - Quad Definition

    let center = CLLocationCoordinate2D(
        latitude: 43.60437434240585,
        longitude: -116.20434424771985
    )

    var radius: Double = 100 {
        didSet {
            updateTask?.cancel()

            updateTask = Task {
                await updateMonitorCondition()
            }

            checkDistanceToQuad()
        }
    }


    // MARK: - Start Monitoring

    func startLocationMonitoring() async {

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


    // MARK: - Stop

    func stop() {

        eventsTask?.cancel()
        updateTask?.cancel()

        eventsTask = nil
        updateTask = nil
        monitor = nil
    }


    // MARK: - External Location Update

    /// Called by NavigationManager whenever GPS updates.
    func updateUserLocation(_ location: CLLocation) {

        userLocation = location

        checkDistanceToQuad()
    }


    // MARK: - Distance Check

    private func checkDistanceToQuad() {

        guard let userLocation else { return }

        let centerLocation = CLLocation(
            latitude: center.latitude,
            longitude: center.longitude
        )

        let distance = userLocation.distance(from: centerLocation)

        isUserInQuad = distance <= radius
    }


    // MARK: - Monitor Update

    func updateMonitorCondition() async {

        guard let monitor else { return }

        let quadCondition = CLMonitor.CircularGeographicCondition(
            center: center,
            radius: radius
        )

        await monitor.add(quadCondition, identifier: "Quad")
    }


    // MARK: - Event Handling

    private func handleEvent(_ event: CLMonitor.Event) async {

        guard event.identifier == "Quad" else { return }

        await MainActor.run {

            switch event.state {

            case .satisfied:
                isUserInQuad = true

            case .unsatisfied:
                isUserInQuad = false

            default:
                break
            }
        }
    }
}
