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

struct FlightManager {
    let duration : TimeInterval
    let protectedStart : TimeInterval
    let protectedEnd : TimeInterval
    
    let averageAlertInterval : TimeInterval
    
    let start : Date
    let end : Date
   
    init(duration : TimeInterval, interval : TimeInterval, start : Date? = nil, protectedStart : TimeInterval? = nil, protectedEnd : TimeInterval? = nil) {
        self.start = start ?? Date()
        self.end = self.start.addingTimeInterval(duration)
        self.duration = duration
        self.averageAlertInterval = interval
        self.protectedStart = protectedStart ?? 0.0
        self.protectedEnd = protectedEnd ?? 0.0
    }
   
    // This should compute the next
    func computeAlertTimes(randomOffsetRange : TimeInterval = 0.0) -> [Date] {

        let protectedStartDate = start.addingTimeInterval(protectedStart)
        let protectedEndDate = end.addingTimeInterval(-protectedEnd)

        let effectiveDuration = duration - (protectedStart + protectedEnd)

        var alertTimes: [Date] = []
        if effectiveDuration > 0 {
            var currentTime = protectedStartDate.addingTimeInterval(self.averageAlertInterval)
            let offsetRange = randomOffsetRange
            
            while currentTime < protectedEndDate {
                let randomOffset = TimeInterval.random(in: -offsetRange...offsetRange)
                
                // Add the random offset to the current alert time
                let randomAlertTime = currentTime.addingTimeInterval(randomOffset)
                
                // Ensure the random alert time stays within the valid range
                if randomAlertTime >= protectedStartDate && randomAlertTime <= protectedEndDate {
                    alertTimes.append(randomAlertTime)
                }
                
                // Move to the next regular alert time
                currentTime = currentTime.addingTimeInterval(averageAlertInterval)
            }
        } else {
            Logger.app.error("Flight duration is less than protected start and end")
        }
        return alertTimes
    }
}

