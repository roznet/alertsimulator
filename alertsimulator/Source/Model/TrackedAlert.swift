//  MIT License
//
//  Created on 10/01/2025 for alertsimulator
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
import UserNotifications

struct TrackedAlert : Codable {
    let identifier: String
    let date: Date
    let flightAlert : FlightAlert
    
    var isExpired: Bool { date < Date() }
    
    init(date: Date, alert: FlightAlert, identifier: String? = nil) {
        self.identifier = identifier ?? UUID().uuidString
        self.date = date
        self.flightAlert = alert
    }
    var summaryDescription : String {
        let message = flightAlert.message ?? ""
        return "\(identifier) - \(date) - \(flightAlert.alertType) \(message)"
    }
}

extension TrackedAlert {
    var notificationContent : UNNotificationContent {
        return self.flightAlert.notificationContent
    }
}
