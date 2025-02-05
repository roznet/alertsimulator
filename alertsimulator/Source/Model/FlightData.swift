import Foundation

class FlightData: ObservableObject {
    @Published var pitch: Double // degrees (-90 to +90)
    @Published var roll: Double  // degrees (-180 to +180)
    @Published var airspeed: Double // knots
    @Published var altitude: Double // feet
    @Published var verticalSpeed: Double // feet per minute
    
    init(pitch: Double = 0,
         roll: Double = 0,
         airspeed: Double = 0,
         altitude: Double = 0,
         verticalSpeed: Double = 0) {
        self.pitch = pitch
        self.roll = roll
        self.airspeed = airspeed
        self.altitude = altitude
        self.verticalSpeed = verticalSpeed
    }
} 