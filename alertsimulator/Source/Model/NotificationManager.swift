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
import UserNotifications
import OSLog

extension Notification.Name {
    static let didReceiveSimulatedAlert = Notification.Name("didReceiveSimulatedAlert")
    static let notificationWereUpdated = Notification.Name("notificationWereUpdated")
}

class NotificationManager : NSObject, UNUserNotificationCenterDelegate {
    private var trackedNotifications: [String: TrackedAlert] = [:]
    
    private let center = UNUserNotificationCenter.current()
    
    override init () {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permissions at startup
        checkAuthorization { success in
            if success {
                Logger.app.info("Notification permissions granted")
            } else {
                Logger.app.info("Notification permissions not granted")
            }
        }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // always display even if the app is up
        completionHandler([.banner,.sound,.badge])
    }
    
    func fromSettings() {
        let tracked = Settings.shared.currentTrackedNotifications
        center.getPendingNotificationRequests { requests in
            var newTrackedNotifications: [String: TrackedAlert] = tracked
            requests.forEach { request in
                if let notification = self.trackedNotifications[request.identifier]  {
                    newTrackedNotifications[notification.identifier] = notification
                }
            }
            self.trackedNotifications = newTrackedNotifications
            Logger.app.info("Found \(newTrackedNotifications.count)/\(tracked.count) valid tracked notifications")
            for notification in self.trackedNotifications.values {
                Logger.app.info("loaded \(notification.summaryDescription)")
            }
        }
    }
    func toSettings() {
        Settings.shared.currentTrackedNotifications = self.trackedNotifications
        Logger.app.info("Saving \(self.trackedNotifications.count) notifications")
        let check = Settings.shared.currentTrackedNotifications
        Logger.app.info("Saved \(check.count) notifications")
        for notification in Settings.shared.currentTrackedNotifications.values {
            Logger.app.info("saved \(notification.summaryDescription)")
        }
    }
   
    func checkAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            if !success {
                Logger.app.error("No authorization \(String(describing: error))")
            }
            completion(success)
        }
    }

    public func cancelAll() {
        center.removeAllPendingNotificationRequests()
        self.trackedNotifications = [:]
        Logger.app.info("Cancelled all notifications")
        NotificationCenter.default.post(name: .notificationWereUpdated, object: nil)
    }
    
    public func scheduleNext(tracked : TrackedAlert) {
        checkAuthorization() { success in
            guard success else {
                Logger.app.error("No authorization")
                return
            }
            let delay = tracked.date.timeIntervalSinceNow
            if delay > 0 {
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
                self.trackedNotifications[tracked.identifier] = tracked
                Logger.app.info("Scheduling alert for \(delay) seconds")
                let request = UNNotificationRequest(identifier: tracked.identifier, content: tracked.notificationContent, trigger: trigger)
                self.center.add(request) { error in
                    if let error = error {
                        Logger.app.error("Error adding request \(error)")
                    }
                    self.toSettings()
                    NotificationCenter.default.post(name: .notificationWereUpdated, object: nil)
                }
            }else{
                Logger.app.error( "Delay must be greater than zero")
            }
        }
    }
    
    func getPendingNotifications(completionHandler : @escaping ([TrackedAlert]) -> Void) {
        center.getPendingNotificationRequests { requests in
            var trackedNotifications : [TrackedAlert] = []
            for request in requests {
                if let tracked = self.trackedNotifications[request.identifier] {
                    trackedNotifications.append(tracked)
                }else{
                    Logger.app.error( "Could not find tracked notification for \(request.identifier)")
                }
            }
            completionHandler(trackedNotifications)
        }
    }
    
    func scheduleAll(for flightManager : Flight)  {
        self.cancelAll()
        
        for alert in flightManager.flightAlerts {
            self.scheduleNext(tracked: alert)
        }
    }
    
   
    var lastNotification : TrackedAlert? = nil
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let tracked = self.trackedNotifications[response.notification.request.identifier] {
            Logger.app.info("didReceive alert: \(tracked.summaryDescription)")
            self.lastNotification = tracked
            NotificationCenter.default.post(name: .didReceiveSimulatedAlert, object: tracked.alert)
            NotificationCenter.default.post(name: .notificationWereUpdated, object: tracked.alert)
            self.trackedNotifications.removeValue(forKey: tracked.identifier)
        }else {
            Logger.app.error("didReceive unknown alert identifier: \(response.notification.request.identifier)")
        }
        completionHandler()
    }
}
