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
}

class NotificationManager : NSObject, UNUserNotificationCenterDelegate {
    private let center = UNUserNotificationCenter.current()
    
    override init () {
        super.init( )
        UNUserNotificationCenter.current().delegate = self
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // always display even if the app is up
        completionHandler([.banner,.sound,.badge])
    }
   
    private func checkAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { success, _ in
            completion(success)
        }
    }
    public func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }
    
    public func startNext(alert simulatedAlert: SimulatedAlert) {
        self.scheduleNext(alert: simulatedAlert)
    }
    public func scheduleNext(alert : SimulatedAlert, date : Date? = nil) {
        guard let date = date else { return }
        
        checkAuthorization() { success in
            guard success else {
                Logger.app.error("No authorization")
                return
            }
            let delay = date.timeIntervalSinceNow
            if delay > 0 {
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
                Logger.app.info("Scheduling alert for \(delay) seconds")
                let request = UNNotificationRequest(identifier: alert.uniqueIdentifier, content: alert.notificationContent, trigger: trigger)
                self.center.add(request) { error in
                    if let error = error {
                        Logger.app.error("Error adding request \(error)")
                    }
                }
            }else{
                Logger.app.error( "Delay must be greater than zero")
            }
        }
    }
    
    func checkPendingNotification() {
        center.getPendingNotificationRequests { requests in
            requests.forEach { request in
                Logger.app.info("Pending notification: \(request)")
            }
        }
    }
    
    func scheduleNext(flightManager : FlightManager, alertManager : AlertManager)  {
        center.removeAllPendingNotificationRequests()
        
        for date in flightManager.alertTimes {
            let alert = alertManager.drawNextAlert()
            self.scheduleNext(alert: alert, date: date)
        }
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let alert = SimulatedAlert.alert(for: response.notification.request.identifier) {
            Logger.app.info("didReceive alert: \(alert)")
            NotificationCenter.default.post(name: .didReceiveSimulatedAlert, object: alert)
        }else {
            Logger.app.error("didReceive unknown alert identifier: \(response.notification.request.identifier)")
        }
        completionHandler()
    }
}
