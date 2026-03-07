import SwiftUI
import MapKit

struct MapView: View {
    @Binding var selectedBuilding: Building?
    let userLocation: CLLocation?
    let buildings: [Building]
    
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        Map(position: $position) {
            UserAnnotation()
            
            ForEach(buildings) { building in
                Annotation(building.name, coordinate: building.coordinate) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title)
                        .foregroundStyle(selectedBuilding == building ? .blue : .red)
                        .onTapGesture { selectedBuilding = building }
                }
            }
        }
    }
}
