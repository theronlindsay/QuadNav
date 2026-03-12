import SwiftUI
import CoreLocation
import ARKit

struct ContentView: View {

    // MARK: State Objects
    
    @State private var navManager = NavigationManager()
    @State private var locationMonitor = LocationMonitor()
    @State private var arSessionManager = ARSessionManager()
    @State private var recenterTrigger = UUID()
    
    @State private var currentMode: ARMode = .map
    @State private var showDebugView = false
    @State private var showQuadDistance = false


    // MARK: Distance Helper
    
    var distanceToQuad: Double {
        guard let userLocation = navManager.userLocation else { return 0 }

        let quadCenter = CLLocation(
            latitude: locationMonitor.center.latitude,
            longitude: locationMonitor.center.longitude
        )

        return userLocation.distance(from: quadCenter)
    }


    // MARK: UI
    
    var body: some View {

        ZStack {

            // MARK: Map / AR Layer
            
            if currentMode == .ar {

                ARNavigationView(
                    sessionManager: arSessionManager,
                    locationMonitor: locationMonitor
                )
                .ignoresSafeArea()

            }
            else if currentMode == .split {

                VStack(spacing: 0) {

                    ARNavigationView(
                        sessionManager: arSessionManager,
                        locationMonitor: locationMonitor
                    )
                    .frame(maxHeight: UIScreen.main.bounds.height / 2)

                    ZStack {

                        MapView(
                            selectedBuilding: $navManager.selectedBuilding,
                            userLocation: navManager.userLocation,
                            buildings: Building.campusBuildings,
                            recenterTrigger: recenterTrigger
                        )

                        if navManager.selectedBuilding != nil {
                            DirectionArrowView(angle: navManager.relativeBearing)
                                .frame(width: 140, height: 140)
                                .shadow(radius: 5)
                                .animation(.spring, value: navManager.targetBearing)
                        }
                    }
                }
                .ignoresSafeArea()

            }
            else {

                ZStack {

                    MapView(
                        selectedBuilding: $navManager.selectedBuilding,
                        userLocation: navManager.userLocation,
                        buildings: Building.campusBuildings,
                        recenterTrigger: recenterTrigger
                    )

                    if navManager.selectedBuilding != nil {
                        DirectionArrowView(angle: navManager.relativeBearing)
                            .frame(width: 140, height: 140)
                            .shadow(radius: 5)
                            .animation(.spring, value: navManager.targetBearing)
                    }
                }
                .ignoresSafeArea()
            }


            // MARK: Overlay UI
            
            VStack(spacing: currentMode == .map ? 6 : 12) { // tighter spacing in full map

                Picker("Navigation Mode", selection: $currentMode) {
                    Text("Map").tag(ARMode.map)
                    Text("Split").tag(ARMode.split)
                    Text("AR").tag(ARMode.ar)
                }
                .pickerStyle(.segmented)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .padding(.horizontal)

                VStack(spacing: currentMode == .map ? 2 : 4) { // tighter spacing in full map
                    HStack {
                        Text(navManager.selectedBuilding?.name ?? "Select a Building")
                            .font(.headline)

                        Spacer()

                        Button {
                            showDebugView = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                        }
                    }

                    Text("\(Int(navManager.distanceToTarget)) meters away")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if showQuadDistance {
                        Text("Quad Distance: \(Int(distanceToQuad)) m")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)

                Spacer()

                HStack {

                    Button {
                        recenterTrigger = UUID()
                    } label: {
                        Label("Recenter", systemImage: "location.fill")
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .cornerRadius(10)
                    }

                    Spacer()

                    Picker("Target", selection: $navManager.selectedBuilding) {

                        Text("📍 Select Destination")
                            .tag(nil as Building?)

                        ForEach(Building.campusBuildings) { building in
                            Text(building.name)
                                .tag(building as Building?)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(5)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                }
            }
            // Mode-specific top padding to push overlay down in full map
            .padding(.top, currentMode == .map ? 50 : 0)
            .padding()
        }

        // MARK: Debug Sheet
        
        .sheet(isPresented: $showDebugView) {
            DebugView()
        }

        // MARK: Data Sync
        
        .onChange(of: navManager.userLocation) { _, newValue in
            if let location = newValue {
                locationMonitor.updateUserLocation(location)
            }
        }

        .onChange(of: navManager.targetBearing) { _, newValue in
            arSessionManager.targetBearing = newValue
        }
    }
}
