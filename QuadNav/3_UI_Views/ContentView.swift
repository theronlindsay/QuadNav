import SwiftUI

struct ContentView: View {
    @State private var navManager = NavigationManager()
    @State private var locationMonitor = LocationMonitor()
    
    var body: some View {
        ZStack {
            MapView(
                selectedBuilding: $navManager.selectedBuilding,
                userLocation: navManager.userLocation,
                buildings: Building.campusBuildings
            )
            .ignoresSafeArea()
            
            VStack {
                VStack(spacing: 4) {
                    Text(navManager.selectedBuilding?.name ?? "Select a Building")
                        .font(.headline)
                    Text("\(Int(navManager.distanceToTarget)) meters away")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                
                Spacer()
                
                DirectionArrowView(angle: navManager.targetBearing)
                    .frame(width: 140, height: 140)
                
                Spacer()
                
                MapRadiusView(monitor: locationMonitor)
                    .frame(height: 120)
                    .cornerRadius(15)
                    .overlay(RoundedRectangle(cornerRadius: 15).stroke(.white, lineWidth: 2))
                
                Picker("Target", selection: $navManager.selectedBuilding) {
                    Text("📍 Select Destination").tag(nil as Building?)
                    ForEach(Building.campusBuildings) { building in
                        Text(building.name).tag(building as Building?)
                    }
                }
                .pickerStyle(.menu)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)
            }
            .padding()
        }
    }
}
