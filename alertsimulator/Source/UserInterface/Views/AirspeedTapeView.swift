import SwiftUI

struct AirspeedTapeView: View {
    let airspeed: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Speed tape background
                Rectangle()
                    .fill(Color.black)
                
                // Current speed indicator
                Text("\(Int(airspeed))")
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .bold))
                    .background(
                        Rectangle()
                            .stroke(Color.white, lineWidth: 2)
                            .background(Color.black)
                    )
            }
        }
    }
}

#Preview {
    AirspeedTapeView(airspeed: 120)
        .frame(width: 60, height: 200)
        .background(Color.black)
} 