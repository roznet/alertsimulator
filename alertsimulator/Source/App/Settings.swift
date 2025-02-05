//  MIT License
//
//  Created on 28/12/2024 for alertsimulator
//
//  Copyright (c) 2024 Brice Rosenzweig
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//


import Foundation
import RZUtilsSwift
import OSLog

struct Settings {
    static var shared : Settings = Settings()
    
    enum Key : String {
        case aircraft_type = "aircraft_type"
        case current_flight_start = "current_flight_start"
        case current_flight_interval = "current_flight_interval"
        case current_flight_duration = "current_flight_duration"
        case current_flight_alert_times = "current_flight_alert_times"
        case current_tracked_notifications = "current_tracked_notifications"
        case current_aircraft_name = "current_aircraft_name"
        
    }
    
    @UserStorage(key: Key.current_flight_start, defaultValue: Date())
    var currentFlightStart : Date
    
    @UserStorage(key: Key.current_flight_interval, defaultValue: 0.0)
    var currentFlightInterval : TimeInterval
    
    @UserStorage(key: Key.current_flight_duration, defaultValue: 0.0)
    var currentFlightDuration : TimeInterval
    
    @CodableStorage(key: Key.current_flight_alert_times, defaultValue: [])
    var currentFlightAlerts : [TrackedAlert]
    
    @CodableStorage(key: Key.current_tracked_notifications, defaultValue: [:])
    var currentTrackedNotifications : [String:TrackedAlert]
    
    @UserStorage(key: Key.current_aircraft_name, defaultValue: Aircraft.defaultValue.aircraftName)
    var currentAircraftName : String

    var currentAircraft : Aircraft {
        return Aircraft(aircraftName: self.currentAircraftName)
    }
    
    var currentFlight : FlightManager? {
        guard currentFlightInterval > 0 && currentFlightDuration > 0 else { return nil }
        return FlightManager(aircraft: self.currentAircraft, duration: self.currentFlightDuration, interval: self.currentFlightInterval, start: self.currentFlightStart, flightAlerts: self.currentFlightAlerts)
    }
    
}
