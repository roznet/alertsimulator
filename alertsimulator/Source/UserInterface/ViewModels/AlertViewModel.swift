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
    @Published var flightIsRunning : Bool = false
    @Published var selectedDurationHours: Int = 0
    @Published var selectedDurationMinutes: Int = 0
    @Published var selectedIntervalMinutes: Int = 0
    
    @Published var nextAlertTime : Date = Date()
    @Published var hasPendingNotification : Int = 0
    
    @Published var casMessage : CASMessage = CASMessage()
    
    @Published var selectedAircraftName : String = SimulatedAlert.aircrafts.first?.aircraftName ?? "undefined"
    @Published var numberOfAlertForAircraft : Int = 0
    
    private var duration : TimeInterval {
        get {
            return TimeInterval( 3600.0 * Double(selectedDurationHours) + 60.0 * Double(selectedDurationMinutes))
        }
        set {
            selectedDurationHours = Int(newValue / 3600)
            selectedDurationMinutes = Int((newValue - Double(selectedDurationHours * 3600)) / 60)
        }
    }
    private var interval : TimeInterval {
        get {
            return TimeInterval( 60.0 * Double(selectedIntervalMinutes))
        }
        set {
            selectedIntervalMinutes = Int(newValue / 60)
        }
    }
    
    private var aircraft : Aircraft {
        return Aircraft(aircraftName: self.selectedAircraftName)
    }
    var availableAircraftNames : [String] {
        return SimulatedAlert.aircrafts.map { $0.aircraftName }
    }
    
    var flight : Flight = Flight()
    var alertManager : AlertManager = AlertManager()
    var notificationManager : NotificationManager = AlertSimulatorApp.notificationManager
    
    private let intervalStep : Int = 1
    private let minuteStep : Int = 1
   
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
    
    var selectedDurationDescription : String {
        return String(format: "%02d h %02d", selectedDurationHours, selectedDurationMinutes)
    }
    
    var selectedIntervalDescription : String {
        return String(format: "%02d m", selectedIntervalMinutes)
    }

    private var flightEndTimer: Timer?
    private func startTimer(){
        // Set up timer to automatically stop flight at end time
        flightEndTimer?.invalidate() // Clear any existing timer
        flightEndTimer = Timer.scheduledTimer(withTimeInterval: self.duration, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.stopFlight()
            }
        }
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
        flightEndTimer?.invalidate()
    }
    func fromSettings() {
        self.duration = Settings.shared.currentFlightDuration
        self.interval = Settings.shared.currentFlightInterval
        
        self.selectedAircraftName = Settings.shared.currentAircraft.aircraftName
        self.numberOfAlertForAircraft = self.aircraft.alerts.count
        self.flight = Flight(aircraft: self.aircraft, duration: duration, interval: interval, start: Settings.shared.currentFlightStart, flightAlerts: Settings.shared.currentFlightAlerts)
        self.notificationManager.fromSettings()
        Logger.app.info("Settings loaded")
        self.flightIsRunning = self.flight.isRunning()
        if self.flightIsRunning {
            self.startTimer()
        }
    }
    
    
    func updateFromFlight() {
        self.selectedAircraftName = self.flight.aircraft.aircraftName
        self.duration = self.flight.duration
        self.interval = self.flight.averageAlertInterval
        self.flightIsRunning = self.flight.isRunning()
    }
    
    func toSettings() {
        Settings.shared.currentFlightDuration = self.duration
        Settings.shared.currentFlightInterval = self.interval
        Settings.shared.currentFlightStart = self.flight.start
        Settings.shared.currentFlightAlerts = self.flight.flightAlerts
        Settings.shared.currentAircraftName = self.selectedAircraftName
        self.notificationManager.toSettings()
        Logger.app.info("Settings updated")
    }
    
    // Add validation result type
    enum FlightValidationError: String {
        case durationZero = "Flight duration must be greater than 0"
        case intervalZero = "Alert interval must be greater than 0"
        case intervalGreaterThanDuration = "Alert interval must be less than flight duration"
        case notificationsNotAuthorized = "Notifications must be enabled to start flight simulation. Tap OK to open Settings."
    }
    
    func openNotificationSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    // Add validation function
    func validateFlightParameters(completion: @escaping ([FlightValidationError]) -> Void) {
        var errors: [FlightValidationError] = []
        
        if duration <= 0 {
            errors.append(.durationZero)
        }
        
        if interval <= 0 {
            errors.append(.intervalZero)
        }
        
        if interval >= duration && duration > 0 && interval > 0 {
            errors.append(.intervalGreaterThanDuration)
        }
        
        // Check and request notification authorization if needed
        notificationManager.checkAuthorization { authorized in
            if !authorized {
                errors.append(.notificationsNotAuthorized)
            }
            completion(errors)
        }
    }
    
    func startFlight() {
        guard !flight.isRunning() else { return }
        
        // Calculate flight duration in seconds
        self.flight = Flight(aircraft: self.aircraft, duration: self.duration, interval: self.interval)
        // Start the flight
        self.flight.start()
        self.toSettings()
        self.startTimer()
        self.notificationManager.scheduleAll(for: self.flight)
        DispatchQueue.main.async {
            self.flightIsRunning = self.flight.isRunning()
        }
    }
    func stopFlight() {
        self.notificationManager.cancelAll()
        flight.stop()
        self.flightIsRunning = self.flight.isRunning()
        flightEndTimer?.invalidate()
        flightEndTimer = nil
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
