import SwiftUI

struct PrimaryFlightDisplayView: View {
    @ObservedObject var flightData: FlightData
    
    var body: some View {
        HStack(spacing: 2) {
            AirspeedTapeView(airspeed: flightData.airspeed)
                .frame(width: 60)
            
            AttitudeIndicatorView(pitch: flightData.pitch, roll: flightData.roll)
                .frame(maxWidth: .infinity)
            
            VStack(spacing: 2) {
                AltitudeTapeView(altitude: flightData.altitude)
                    .frame(width: 60)
                
                VerticalSpeedIndicator(verticalSpeed: flightData.verticalSpeed)
                    .frame(width: 60)
            }
        }
        .background(Color.black)
        .aspectRatio(16/9, contentMode: .fit)
    }
}

struct AttitudeIndicatorView: View {
    let pitch: Double
    let roll: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Sky and ground
                AttitudeBackground(pitch: pitch, roll: roll)
                
                // Center fixed aircraft symbol
                AircraftSymbol()
                    .stroke(Color.yellow, lineWidth: 3)
                
                // Pitch ladder
                PitchLadder(pitch: pitch, roll: roll)
                 .stroke(Color.white, lineWidth: 1)
                   // Roll indicator
                
                RollIndicator(roll: roll)
                    .stroke(Color.white, lineWidth: 2)
                
            }
        }
        .background(Color.black)
    }
}

struct AttitudeBackground: View {
    let pitch: Double
    let roll: Double
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let center = CGPoint(x: geometry.size.width/2, y: geometry.size.height/2)
                let radius = min(geometry.size.width, geometry.size.height)
                
                // Calculate horizon line position based on pitch and roll
                let pitchOffset = CGFloat(pitch) * radius/180
                let rollRadians = CGFloat(roll) * .pi/180
                
                path.addRect(CGRect(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height/2 - pitchOffset))
            }
            .fill(Color.blue.opacity(0.5)) // Sky
            .rotationEffect(.radians(Double(roll) * .pi/180))
            
            Path { path in
                let center = CGPoint(x: geometry.size.width/2, y: geometry.size.height/2)
                let radius = min(geometry.size.width, geometry.size.height)
                
                let pitchOffset = CGFloat(pitch) * radius/180
                path.addRect(CGRect(x: 0, y: geometry.size.height/2 - pitchOffset, width: geometry.size.width, height: geometry.size.height/2 + pitchOffset))
            }
            .fill(Color.brown.opacity(0.5)) // Ground
            .rotationEffect(.radians(Double(roll) * .pi/180))
        }
    }
}

struct AircraftSymbol: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let centerX = width/2
        let centerY = height/2
        
        // Draw simple aircraft symbol
        path.move(to: CGPoint(x: centerX - 40, y: centerY))
        path.addLine(to: CGPoint(x: centerX + 40, y: centerY))
        path.move(to: CGPoint(x: centerX, y: centerY - 40))
        path.addLine(to: CGPoint(x: centerX, y: centerY + 40))
        
        return path
    }
}

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

struct RollIndicator: Shape {
    let roll: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let centerX = width/2
        let centerY = height/2
        let radius = min(width, height) * 0.4
        
        let fromAngle: Int = -60-90
        let toAngle: Int = 60-90
        
        // Draw the arc for roll indication
        path.addArc(center: CGPoint(x: centerX, y: centerY),
                   radius: radius,
                    startAngle: .degrees(Double(fromAngle)),
                    endAngle: .degrees(Double(toAngle)),
                   clockwise: false)
        
        // Add tick marks
        for angle in stride(from: fromAngle, through: toAngle, by: 10) {
            let tickLength = angle % 30 == 0 ? 15.0 : 10.0
            let angleInRadians = Double(angle) * .pi / 180
            let startX = centerX + CGFloat(cos(angleInRadians)) * radius
            let startY = centerY + CGFloat(sin(angleInRadians)) * radius
            let endX = centerX + CGFloat(cos(angleInRadians)) * (radius - tickLength)
            let endY = centerY + CGFloat(sin(angleInRadians)) * (radius - tickLength)
            
            path.move(to: CGPoint(x: startX, y: startY))
            path.addLine(to: CGPoint(x: endX, y: endY))
        }
        
        // Add roll pointer
        path.move(to: CGPoint(x: centerX, y: centerY - radius + 20))
        path.addLine(to: CGPoint(x: centerX - 10, y: centerY - radius + 30))
        path.addLine(to: CGPoint(x: centerX + 10, y: centerY - radius + 30))
        path.closeSubpath()
        
        return path
    }
}

struct PitchLadder: Shape {
    let pitch: Double
    let roll: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let centerX = width/2
        let centerY = height/2
        let scale = height/60.0 // Scale factor for pitch lines (30 degrees visible)
        
        // Draw pitch lines every 5 degrees
        for pitchAngle in stride(from: -30.0, through: 30.0, by: 5.0) {
            let y = centerY + CGFloat(pitchAngle - pitch) * scale
            let lineWidth = (abs(pitchAngle).truncatingRemainder(dividingBy: 10.0) == 0) ? width/4 : width/6
            
            // Draw line
            path.move(to: CGPoint(x: centerX - lineWidth/2, y: y))
            path.addLine(to: CGPoint(x: centerX + lineWidth/2, y: y))
            
            // Add pitch numbers for 10-degree increments
            if abs(pitchAngle).truncatingRemainder(dividingBy: 10.0) == 0 && pitchAngle != 0 {
                // Numbers would be added here in a more complete implementation
            }
        }
        
        return path
    }
}

#Preview {
    PrimaryFlightDisplayView(
        flightData: FlightData(
            pitch: 5,
            roll: 10,
            airspeed: 120,
            altitude: 5500,
            verticalSpeed: 500
        )
    )
    .frame(width: 800, height: 450)
} 
