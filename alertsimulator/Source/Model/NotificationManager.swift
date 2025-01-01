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
    public func scheduleNext(alert : SimulatedAlert) {
        checkAuthorization() { success in
            guard success else {
                Logger.app.error("No authorization")
                return
            }
            
            let time : TimeInterval = 1
            let random = Double.random(in: 1...5)
            let delay : TimeInterval = time + random
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
            Logger.app.info("Scheduling alert for \(delay) seconds")
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: alert.notificationContent, trigger: trigger)
            self.center.add(request) { error in
                if let error = error {
                    Logger.app.error("Error adding request \(error)")
                }
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Logger.app.info("didReceive response: \(response)")
        completionHandler()
    }
}
