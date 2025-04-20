//  MIT License
//
//  Created on 01/01/2025 for alertsimulator
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
import OSLog


struct Flight {
    let aircraft : Aircraft
    let duration : TimeInterval
    let protectedStart : TimeInterval
    let protectedEnd : TimeInterval
    
    let averageAlertInterval : TimeInterval
    
    let start : Date
    let end : Date
    
    var flightAlerts : [TrackedAlert]

    func isRunning(at : Date = Date()) -> Bool {
        return at >= start && at <= end && !flightAlerts.isEmpty
    }
    
    var alertManager : AlertManager
   
    init(aircraft : Aircraft = Aircraft.defaultValue, duration : TimeInterval = 0.0, interval : TimeInterval = 0.0, start : Date? = nil, protectedStart : TimeInterval? = nil, protectedEnd : TimeInterval? = nil,
         flightAlerts : [TrackedAlert] = []) {
        self.aircraft = aircraft
        self.start = start ?? Date()
        self.end = self.start.addingTimeInterval(duration)
        self.duration = duration
        self.averageAlertInterval = interval
        self.protectedStart = protectedStart ?? 0.0
        self.protectedEnd = protectedEnd ?? 0.0
        self.flightAlerts = flightAlerts
        self.alertManager = AlertManager(aircraft: self.aircraft)
    }
  
    mutating func start(alertParameters : AlertParameters) {
        self.alertManager.reset()
        self.computeAlerts(alertParameters : alertParameters)
    }
   
    mutating func stop() {
        self.flightAlerts = []
    }
    
    func nextAlert(after : Date) -> TrackedAlert? {
        if let nextAlertTime = flightAlerts.first(where: { $0.date > after }) {
            return nextAlertTime
        } else {
           return nil
        }
    }
    
    mutating func immediateAlert(alertParameters : AlertParameters) -> TrackedAlert {
        let tracked = TrackedAlert(date: Date().addingTimeInterval(1.0), alert: self.alertManager.drawNextAlert(alertParameters: alertParameters))
        self.flightAlerts.append(tracked)
        self.flightAlerts.sort(by: { $0.date < $1.date })
        return tracked
    }
    
    // This should compute the next
    @discardableResult
    mutating func computeAlerts(alertParameters : AlertParameters) -> [TrackedAlert] {

        let protectedStartDate = start.addingTimeInterval(protectedStart)
        let protectedEndDate = end.addingTimeInterval(-protectedEnd)

        let effectiveDuration = duration - (protectedStart + protectedEnd)
        
        self.flightAlerts = []
        if effectiveDuration > 0 && averageAlertInterval > 0 {
            var currentTime = protectedStartDate.addingTimeInterval(self.averageAlertInterval)
            let offsetRange = alertParameters.randomOffsetRange
            
            while currentTime < protectedEndDate {
                let randomOffset = TimeInterval.random(in: -offsetRange...offsetRange)
                
                // Add the random offset to the current alert time
                let randomAlertTime = currentTime.addingTimeInterval(randomOffset)
                
                // Ensure the random alert time stays within the valid range
                if randomAlertTime >= protectedStartDate && randomAlertTime <= protectedEndDate {
                    self.flightAlerts.append(TrackedAlert(date: randomAlertTime, alert: self.alertManager.drawNextAlert(alertParameters: alertParameters)))
                }
                
                // Move to the next regular alert time
                currentTime = currentTime.addingTimeInterval(averageAlertInterval)
            }
        } else {
            Logger.app.error("Flight duration is less than protected start and end")
        }
        self.flightAlerts.sort(by: { $0.date < $1.date })
        return self.flightAlerts
    }
}

