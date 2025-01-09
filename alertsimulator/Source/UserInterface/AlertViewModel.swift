//  MIT License
//
//  Created on 04/01/2025 for alertsimulator
//
//  Copyright (c) 2025 Brice Rosenzweig
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
import SwiftUI
import OSLog

class AlertViewModel: ObservableObject {
    
    @Published var selectedDurationHours: Int = 0
    @Published var selectedDurationMinutes: Int = 0
    @Published var selectedIntervalMinutes: Int = 0
    
    @Published var nextAlertTime : Date = Date()
    
    @Published var casMessage : CASMessage = CASMessage()
    
    var duration : TimeInterval {
        return TimeInterval( 60.0 * 60.0 * Double(selectedDurationHours) + 60.0 * Double(selectedDurationMinutes))
    }
    var interval : TimeInterval {
        return TimeInterval( 60.0 * Double(selectedIntervalMinutes))
    }
    
    func fromSettings() {
        let duration = Settings.shared.currentFlightDuration
        let interval = Settings.shared.currentFlightInterval
        
        let hours = Int(duration / 60.0 / 60.0)
        let minutes = Int(duration / 60.0) % 60
        
        let intervalMinutes = Int(interval / 60.0) % 60
        
        selectedDurationHours = hours
        self.selectedDurationMinutes = minutes
        selectedIntervalMinutes = intervalMinutes
        self.flight = FlightManager(duration: duration, interval: interval, start: Settings.shared.currentFlightStart, alertTimes: Settings.shared.currentFlightAlertTimes)
    }
    
    func toSettings() {
        
        let duration = TimeInterval( 60.0 * 60.0 * Double(selectedDurationHours) + 60.0 * Double(selectedDurationMinutes))
        let interval = TimeInterval( 60.0 * Double(selectedIntervalMinutes))
        
        Settings.shared.currentFlightDuration = duration
        Settings.shared.currentFlightInterval = interval
        Settings.shared.currentFlightStart = self.flight.start
        Settings.shared.currentFlightAlertTimes = self.flight.alertTimes
    }
   
    var flight : FlightManager = FlightManager(duration: 0.0, interval: 0.0)
    
    func startFlight() {
        self.flight = FlightManager(duration: duration, interval: interval, start: Date())
        self.flight.start()
        self.toSettings()
        AlertSimulatorApp.notificationManager.scheduleNext(flightManager: self.flight, alertManager: AlertSimulatorApp.alertManager)
    }
    
}
