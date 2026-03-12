import SwiftUI
import RealityKit

struct ARNavigationView: View {
    @Bindable var sessionManager: ARSessionManager
    @Bindable var locationMonitor: LocationMonitor
    
    var body: some View {
        ZStack {
            // AR Scene
            ARViewContainer(sessionManager: sessionManager)
                .edgesIgnoringSafeArea(.all)
            
            // Bottom overlay
            VStack {
                Spacer()
                
                HStack {
                    // Navigation status text
                    if locationMonitor.isUserInQuad {
                        Text("Destination Reached")
                            .padding(8)
                            .background(Color.green.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    } else {
                        Text("Navigating...")
                            .padding(8)
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                    
                    // Optional 2D arrow in AR — remove if redundant
                    // Uncomment only if you want it
                    /*
                    Image(systemName: "location.north.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(sessionManager.relativeBearing))
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                    */
                }
                .padding()
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    var sessionManager: ARSessionManager
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        sessionManager.setupARView(in: arView)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}
