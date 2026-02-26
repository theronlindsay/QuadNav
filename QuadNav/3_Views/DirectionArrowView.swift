//
//  DirectionArrowView.swift
//  QuadNav
//
//  Created by Brandon Williams on 2/25/26.
//

import SwiftUI

struct DirectionArrowView: View {

    let rotationAngle: Double
    let distance: Double?

    var body: some View {
        VStack {
            Image(systemName: "arrow.up")
                .resizable()
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(rotationAngle))

            if let distance = distance {
                Text("\(Int(distance)) meters away")
            }
        }
    }
}
