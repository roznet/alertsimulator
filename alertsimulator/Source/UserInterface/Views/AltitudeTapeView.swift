import SwiftUI

struct AltitudeTapeView: View {
    let altitude: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Altitude tape background
                Rectangle()
                    .fill(Color.black)
                
                // Current altitude indicator
                Text("\(Int(altitude))")
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

struct VerticalSpeedIndicator: View {
    let verticalSpeed: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // VSI background
                Rectangle()
                    .fill(Color.black)
                
                // VSI indicator
                Text("\(Int(verticalSpeed))")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .bold))
            }
        }
    }
}

struct CombinedAltitudeView: View {
    let altitude: Double
    let verticalSpeed: Double
    
    var body: some View {
        VStack(spacing: 2) {
            AltitudeTapeView(altitude: altitude)
            VerticalSpeedIndicator(verticalSpeed: verticalSpeed)
        }
    }
}

#Preview("Altitude Tape") {
    AltitudeTapeView(altitude: 5500)
        .frame(width: 100, height: 200)
        .background(Color.black)
    VerticalSpeedIndicator(verticalSpeed: 500)
        .frame(width: 60, height: 100)
        .background(Color.black)
    CombinedAltitudeView(altitude: 15500, verticalSpeed: 500)
        .frame(width: 100, height: 300)
        .background(Color.black)
} 
