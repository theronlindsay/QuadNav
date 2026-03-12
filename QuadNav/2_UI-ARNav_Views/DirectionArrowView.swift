//
// DirectionArrowView.swift
// Created by Brandon Williams & Amber
//

import SwiftUI

// MARK: - Directional Arrow View
// Displays a rotating arrow pointing toward a destination
struct DirectionArrowView: View {
    
    // MARK: Properties
    
    /// Rotation angle in degrees
    let angle: Double
    
    
    // MARK: Body
    
    var body: some View {
        VStack {
            
            // Arrow images stacked
            ZStack {
                
                Image(systemName: "location.north.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(angle)) // Rotate arrow
                    .animation(.easeOut(duration: 0.2), value: angle)
                    .foregroundStyle(.orange)
                    .shadow(radius: 4)
                
                Image(systemName: "location.north")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
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
