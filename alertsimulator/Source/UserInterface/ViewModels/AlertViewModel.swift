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

extension Notification.Name {
    static let aircraftChanged = Notification.Name("aircraftChanged")
}

class AlertViewModel: ObservableObject {
    
    @Published var selectedDurationHours: Int = 0
    @Published var selectedDurationMinutes: Int = 0
    @Published var selectedIntervalMinutes: Int = 0
    
    @Published var nextAlertTime : Date = Date()
    @Published var hasPendingNotification : Int = 0
    
    @Published var casMessage : CASMessage = CASMessage()
    
    @Published var selectedAircraftName : String = SimulatedAlert.aircrafts.first?.aircraftName ?? "undefined"
    @Published var numberOfAlertForAircraft : Int = 0
    
    var duration : TimeInterval {
        return TimeInterval( 60.0 * 60.0 * Double(selectedDurationHours) + 60.0 * Double(selectedDurationMinutes))
    }
    var interval : TimeInterval {
        return TimeInterval( 60.0 * Double(selectedIntervalMinutes))
    }
    
    var aircraft : Aircraft {
        return Aircraft(aircraftName: self.selectedAircraftName)
    }
    var availableAircraftNames : [String] {
        return SimulatedAlert.aircrafts.map { $0.aircraftName }
    }
    
    var flight : FlightManager = FlightManager()
    var alertManager : AlertManager = AlertManager()
    var notificationManager : NotificationManager = AlertSimulatorApp.notificationManager
    
    let intervalStep : Int = 1
    let minuteStep : Int = 1
   
    var hourChoices : [Int] {
        Array(0..<10)
    }
    var minuteChoices : [Int] {
        let numberOfMinute = 60 / self.minuteStep
        return (0..<numberOfMinute).map { $0 * self.minuteStep }
    }
    var intervalChoices : [Int] {
        let numberOfInterval = 60 / intervalStep
        return (0..<numberOfInterval).map { $0 * intervalStep }
    }

    init() {
        if let last = self.notificationManager.lastNotification {
            self.casMessage = last.alert.casMessage
        }
        NotificationCenter.default.addObserver(forName: .didReceiveSimulatedAlert, object: nil, queue: nil){ notification in
            if let simulatedAlert = notification.object as? SimulatedAlert{
                Logger.app.info("Processing \(simulatedAlert)")
                DispatchQueue.main.async {
                    self.casMessage = simulatedAlert.casMessage
                }
            }
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    func fromSettings() {
        let duration = Settings.shared.currentFlightDuration
        let interval = Settings.shared.currentFlightInterval
        
        let hours = Int(duration / 60.0 / 60.0)
        let minutes = Int(duration / 60.0) % 60
        
        let intervalMinutes = Int(interval / 60.0) % 60
        self.selectedAircraftName = Settings.shared.currentAircraft.aircraftName
        
        self.selectedDurationHours = hours
        self.numberOfAlertForAircraft = self.aircraft.alerts.count
        self.selectedDurationMinutes = minutes
        self.selectedIntervalMinutes = intervalMinutes
        self.flight = FlightManager(aircraft: self.aircraft, duration: duration, interval: interval, start: Settings.shared.currentFlightStart, flightAlerts: Settings.shared.currentFlightAlerts)
        self.notificationManager.fromSettings()
        Logger.app.info("Settings loaded")
    }
    
    func toSettings() {
        
        let duration = TimeInterval( 60.0 * 60.0 * Double(selectedDurationHours) + 60.0 * Double(selectedDurationMinutes))
        let interval = TimeInterval( 60.0 * Double(selectedIntervalMinutes))
        
        Settings.shared.currentFlightDuration = duration
        Settings.shared.currentFlightInterval = interval
        Settings.shared.currentFlightStart = self.flight.start
        Settings.shared.currentFlightAlerts = self.flight.flightAlerts
        Settings.shared.currentAircraftName = self.selectedAircraftName
        self.notificationManager.toSettings()
        Logger.app.info("Settings updated")
    }
    
    func startFlight() {
        self.flight = FlightManager(duration: duration, interval: interval, start: Date())
        self.alertManager.reset()
        self.flight.start()
        self.toSettings()
        self.notificationManager.scheduleAll(for: self.flight)
    }
    
    func stopFlight() {
        self.notificationManager.cancelAll()
        self.flight.stop()
    }
    
    func generateSingleAlert() {
        let alert = self.flight.immediateAlert()
        self.notificationManager.scheduleNext(tracked: alert)
    }
    
    func clearAlerts() {
        self.casMessage = CASMessage()
    }
    
    func checkNotifications() {
        self.notificationManager.getPendingNotifications() {
            notifications in
            if notifications.isEmpty {
                Logger.app.info("No notifications")
                DispatchQueue.main.async {
                    self.hasPendingNotification = 0
                }
            }
            var next : TrackedAlert? = nil
            var future : Int = 0
            let now = Date()
            for notification in notifications {
                if notification.date < now {
                    Logger.app.info("Past: \(notification.date): \(notification.alert)")
                    continue
                }
                Logger.app.info("at \(notification.date): \(notification.alert)")
                future += 1
                if next == nil || notification.date < next!.date {
                    Logger.app.info("New next: \(notification.date)")
                    next = notification
                }
                Logger.app.info("\(notification.date): \(notification.alert)")
            }
            Logger.app.info("Next: \(next?.date.formatted() ?? "none")")
            DispatchQueue.main.async {
                self.hasPendingNotification = future
                if let next = next {
                    self.nextAlertTime = next.date
                }
            }
        }
    }
    
    func updateAircraft() {
        // If aircraft change, make sure all current alerts are canceled
        self.numberOfAlertForAircraft = self.aircraft.alerts.count
        self.stopFlight()
        self.clearAlerts()
        
        NotificationCenter.default.post(name: .aircraftChanged, object: nil)
    }
    
}
