import SwiftUI

struct DirectionArrowView: View {
    let angle: Double
    
    var body: some View {
        VStack {
            Image(systemName: "arrow.up")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(angle))
                .foregroundStyle(.red)
                .shadow(radius: 4)
            
            Text("Follow Arrow")
                .font(.caption)
                .bold()
                .padding(.top, 5)
        }
    }
}
