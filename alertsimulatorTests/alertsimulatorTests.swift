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
        
        let manager = AlertManager()
        #expect(manager.available.count > 0)
        for _ in 1...5 {
            let alert = manager.drawNextAlert( )
            print( alert )
        }
        
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
            let flight = FlightManager(duration: oneHour, interval: interval,  start: date, protectedStart: protected, protectedEnd: protected)
            let times = flight.computeAlertTimes(randomOffsetRange: offset )
            let intervals = times.map { ($0.timeIntervalSince(date) - protected) / interval}
            let expected = Array(stride(from: 0.0, to: Double(times.count), by: 1.0)).map { $0 + 1.0}
            let tolerance = offset + 0.00001
            
            #expect(times.count > 0)
            #expect(intervals.count == expected.count)
            for (value1, value2) in zip(intervals, expected) {
                #expect(abs((value1 - value2)) < tolerance)
            }
        }
    }

}
