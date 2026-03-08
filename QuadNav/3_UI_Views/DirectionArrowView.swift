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
                
            
            // SF Symbol arrow outline icon provided by Apple.
          Image(systemName: "location.north.fill")
                
                // Allows the image to resize instead of staying fixed.
                .resizable()
                
                // Keeps the arrow's proportions correct while resizing.
                .scaledToFit()
                
                // Sets the size of the arrow.
                .frame(width: 80, height: 80)
                
                // Rotates the arrow based on the angle value.
                // This is how the arrow points toward the target location.
                .rotationEffect(.degrees(angle))
                
                // Sets the arrow color.
                .foregroundStyle(.orange)
                
                // Adds a small shadow for better visibility.
                .shadow(radius: 4)
                
                Image(systemName: "location.north")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(angle))
                    .foregroundStyle(.blue)
                    .shadow(radius: 4)
            
            }
            // Instruction text displayed under the arrow.
            Text("Follow Arrow")
                .font(.caption)   // Small caption-style text
                .bold()           // Makes the text bold
                .padding(.top, 5) // Adds a little space above the text
        }
    }
}
