//
// DirectionArrowView.swift
// Created by Brandon Williams & Amber
//

import SwiftUI
// SwiftUI lets us build user interfaces in a declarative way.
// Instead of manually managing UIKit elements, we describe what the UI should look like,
// and SwiftUI updates it automatically when state changes.

// MARK: - Direction Arrow View
// This view displays an arrow pointing toward the selected destination.
// It can be used on top of a map or AR view to give the user visual navigation guidance.
struct DirectionArrowView: View {
    
    // MARK: - Properties
    
    /// The angle in degrees the arrow should rotate.
    /// This is calculated in NavigationManager as `relativeBearing`,
    /// which is the difference between the user's heading and the direction to the target.
    let angle: Double
    
    // MARK: - Body
    var body: some View {
        // VStack stacks the arrow image and a label vertically
        VStack {
            
            // ZStack overlays two arrow images for depth and visual clarity
            ZStack {
                
                // MARK: - Foreground Arrow (Orange)
                Image(systemName: "location.north.fill") // Solid arrow
                    .resizable()                         // Make the SF Symbol scalable
                    .scaledToFit()                        // Keep aspect ratio
                    .frame(width: 80, height: 80)        // Fix the size
                    .rotationEffect(.degrees(angle))      // Rotate based on `angle`
                    .animation(.easeOut(duration: 0.2), value: angle) // Smooth rotation animation
                    .foregroundStyle(.orange)            // Set arrow color
                    .shadow(radius: 4)                   // Add subtle shadow for depth
                    
                // MARK: - Background Arrow (Blue)
                Image(systemName: "location.north")      // Outline arrow
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(angle))    // Rotate together with the orange arrow
                    .animation(.easeOut(duration: 0.2), value: angle)
                    .foregroundStyle(.blue)            // Color contrast behind foreground arrow
                    .shadow(radius: 4)
            }
            
            // MARK: - Label
            // Adds text below the arrow for clarity
            Text("Follow Arrow")
                .font(.caption)
                .bold()
                .padding(.top, 5)
        }
    }
}
