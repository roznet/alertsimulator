//
//  alertsimulatorTests.swift
//  alertsimulatorTests
//
//  Created by Brice Rosenzweig on 28/12/2024.
//

import Foundation
import Testing
@testable import alertsimulator

struct alertsimulatorTests {

    @Test func testAlerts() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
       
       
        // This ensures we can read the alert definition files
        // and that the default aircraft is present
        var manager = AlertManager()
        #expect(manager.available.count > 0)
       
        let aircrafts = SimulatedAlert.aircrafts
        #expect(aircrafts.count > 0)
        
        // check each aircraft has some alerts
        for aircraft in aircrafts {
            #expect(aircraft.alerts.count > 0)
        }
        
        let half = manager.available.count / 2
        let total = manager.available.count
        let all = total + half
        var alerts : [Int:Int] = [:]
        // for the first half we should never get the same twice
        var max = 0
        for counter in 1...all {
            let alert = manager.drawNextAlert( )
            if counter <= half {
                #expect(alerts[alert.uid] == nil)
            }
            alerts[alert.uid, default: 0] += 1
            if alerts[alert.uid]! > max {
                max = alerts[alert.uid]!
            }
        }
        #expect(max > 1)
        
    }
    
    @Test func testAlertTimes() async throws {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.minute = 0
        components.second = 0
        let date = Calendar.current.date(from: components)!
            
        
        let oneHour = TimeInterval(3600)
        let oneMinute = TimeInterval(60)
        let tests : [(TimeInterval,TimeInterval,TimeInterval)] = [
            (oneHour/4, 0.0,   0.0),
            (oneHour/4, 2.0 * oneMinute,   0.0),
            (oneHour/4, 2.0 * oneMinute,   10.0*oneMinute),
            (oneHour/4, 0.0,   10.0*oneMinute),
            (oneHour/2, 2.0 * oneMinute,   10.0 * oneMinute),
        ]
        for (interval,offset,protected) in tests {
            var flight = Flight(duration: oneHour, interval: interval,  start: date, protectedStart: protected, protectedEnd: protected)
            let times = flight.computeAlerts(randomOffsetRange: offset )
            let intervals = times.map { ($0.date.timeIntervalSince(date) - protected) / interval}
            let expected = Array(stride(from: 0.0, to: Double(times.count), by: 1.0)).map { $0 + 1.0}
            let tolerance = offset + 0.00001
            
            #expect(times.count > 0)
            #expect(intervals.count == expected.count)
            for (value1, value2) in zip(intervals, expected) {
                #expect(abs((value1 - value2)) < tolerance)
            }
            
            flight.start(randomOffsetRange: offset)
            #expect(flight.isRunning(at: date.addingTimeInterval(5.0)))
            var nextAlert : TrackedAlert? = flight.nextAlert(after: date)
            var extractedDates : [Date] = []
            while let runningAlert = nextAlert {
                extractedDates.append(runningAlert.date)
                nextAlert = flight.nextAlert(after: runningAlert.date)
            }
            #expect(extractedDates.count == times.count)
            // if random offset value won't match
            if offset == 0.0 {
                #expect(extractedDates == times.map { $0.date })
            }
        }
    }
}
