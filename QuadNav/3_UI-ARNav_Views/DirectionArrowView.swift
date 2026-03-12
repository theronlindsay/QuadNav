//Created by Brandon Williams & Amber

import SwiftUI
// SwiftUI is Apple's framework for building user interfaces.
// It lets us describe what the UI should look like using code.


// This struct defines a reusable UI component that displays
// a directional arrow for navigation.
struct DirectionArrowView: View {
    
    // The angle the arrow should rotate to.
    // This value will usually come from the navigation system
    // that calculates the direction toward a destination.
    let angle: Double
    
    
    // The body describes what the view looks like.
    var body: some View {
        
        // VStack stacks the arrow and text vertically.
        VStack {
            
            
            ZStack {
                
                Image(systemName: "location.north.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    
                    // Orientation correction
                    .rotationEffect(.degrees(angle))
                    
                    .animation(.easeOut(duration: 0.2), value: angle)
                    .foregroundStyle(.orange)
                    .shadow(radius: 4)
                
                Image(systemName: "location.north")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    
                    // Orientation correction
                    .rotationEffect(.degrees(angle))
                    
                    .animation(.easeOut(duration: 0.2), value: angle)
                    .foregroundStyle(.blue)
                    .shadow(radius: 4)
            }

            Text("Follow Arrow")
                .font(.caption)
                .bold()
                .padding(.top, 5)
        }
    }
}
