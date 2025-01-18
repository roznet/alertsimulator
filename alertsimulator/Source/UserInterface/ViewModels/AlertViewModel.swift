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
    @Published var hasPendingNotification : Int = 0
    
    @Published var casMessage : CASMessage = CASMessage()
    
    @Published var selectedAircraft : String = SimulatedAlert.aircrafts.first ?? "undefined"
    
    var duration : TimeInterval {
        return TimeInterval( 60.0 * 60.0 * Double(selectedDurationHours) + 60.0 * Double(selectedDurationMinutes))
    }
    var interval : TimeInterval {
        return TimeInterval( 60.0 * Double(selectedIntervalMinutes))
    }
    
    var flight : FlightManager = FlightManager(duration: 0.0, interval: 0.0)
    var alertManager : AlertManager = AlertManager()
    var notificationManager : NotificationManager = AlertSimulatorApp.notificationManager
    
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
        
        selectedDurationHours = hours
        self.selectedDurationMinutes = minutes
        selectedIntervalMinutes = intervalMinutes
        self.flight = FlightManager(duration: duration, interval: interval, start: Settings.shared.currentFlightStart, flightAlerts: Settings.shared.currentFlightAlerts)
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
    
}
