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
        let interval = oneHour/4
        let offset = 0.10
        var flight = FlightManager(duration: oneHour, interval: interval,  start: date, protectedStart: oneMinute * 10, protectedEnd: oneMinute * 10)
        var times = flight.computeAlertTimes(randomOffsetRange: offset )
        #expect(times.count > 0)
        let intervals = times.map { ($0.timeIntervalSince(date) - oneMinute * 10) / interval}
        let expected = Array(stride(from: 0.0, to: Double(times.count), by: 1.0))
        let tolerance = interval * offset + 0.00001
        print(times)
        print(intervals)
        print(expected)
        for (value1, value2) in zip(intervals, expected) {
            #expect(abs((value1 - value2)) < tolerance)
        }

     
        
        
    }

}
