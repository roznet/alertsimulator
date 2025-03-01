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
        case alerts_data_version = "alerts_data_version"
        case alerts_data_url = "alerts_data_url"
        case last_update_check = "last_update_check"
        case alert_repeat_threshold = "alert_repeat_threshold"
        case high_priority_multiplier = "high_priority_multiplier"
        case medium_priority_multiplier = "medium_priority_multiplier"
        case low_priority_multiplier = "low_priority_multiplier"
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

    @UserStorage(key: Key.alerts_data_version, defaultValue: "1.0")
    var alertsDataVersion : String
    
    @UserStorage(key: Key.alerts_data_url, defaultValue: "https://flyfun.aero/latest/AlertsToSimulate.json")
    var alertsDataUrl : String
    
    @UserStorage(key: Key.last_update_check, defaultValue: Date.distantPast)
    var lastUpdateCheck : Date

    @UserStorage(key: Key.alert_repeat_threshold, defaultValue: 5)
    var alertRepeatThreshold: Int
    
    @UserStorage(key: Key.high_priority_multiplier, defaultValue: 10.0)
    var highPriorityMultiplier: Double
    
    @UserStorage(key: Key.medium_priority_multiplier, defaultValue: 5.0)
    var mediumPriorityMultiplier: Double
    
    @UserStorage(key: Key.low_priority_multiplier, defaultValue: 1.0)
    var lowPriorityMultiplier: Double

    var currentAircraft : Aircraft {
        return Aircraft(aircraftName: self.currentAircraftName)
    }
    
    var currentFlight : Flight? {
        guard currentFlightInterval > 0 && currentFlightDuration > 0 else { return nil }
        return Flight(aircraft: self.currentAircraft, duration: self.currentFlightDuration, interval: self.currentFlightInterval, start: self.currentFlightStart, flightAlerts: self.currentFlightAlerts)
    }
    
    // Time interval between update checks (1 day)
    static let updateCheckInterval: TimeInterval = 24 * 60 * 60
    
    var shouldCheckForUpdates: Bool {
        return Date().timeIntervalSince(lastUpdateCheck) >= Settings.updateCheckInterval
    }
}
