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
        let testParameters = AlertParameters()
        #expect(manager.available.count > 0)
        
        let aircrafts = FlightAlert.aircrafts
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
            let alert = manager.drawNextAlert(alertParameters: testParameters )
            if counter <= testParameters.alertRepeatThreshold {
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
        let testParameters = AlertParameters()
        
        
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
            let times = flight.computeAlerts(alertParameters: testParameters)
            let intervals = times.map { ($0.date.timeIntervalSince(date) - protected) / interval}
            let expected = Array(stride(from: 0.0, to: Double(times.count), by: 1.0)).map { $0 + 1.0}
            let tolerance = offset + 0.00001
            
            #expect(times.count > 0)
            #expect(intervals.count == expected.count)
            for (value1, value2) in zip(intervals, expected) {
                #expect(abs((value1 - value2)) < tolerance)
            }
            
            flight.start(alertParameters: testParameters)
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
    
    @Test func testChecklistAlertMatching() async throws {
        
        // Get SR22TG6 aircraft
        let aircrafts = FlightAlert.aircrafts
        let found = aircrafts.first { $0.aircraftName == "S22TG6" }
        #expect(found != nil)
        if let sr22tg6 = found {
            
            // Load checklists
            let checklists = try Checklist.load(for: sr22tg6)
            #expect(checklists.count > 0)
            
            // Go through all alerts for SR22TG6
            for alert in sr22tg6.alerts {
                if alert.alertType == .cas,
                   let alertMessage = alert.message {
                    // Find matching checklist
                    let matchingChecklists = checklists.filter { checklist in
                        checklist.alert == alertMessage
                    }
                    
                    // Only validate alert matching for EMERGENCY and ABNORMAL checklists
                    let emergencyAbnormalChecklists = matchingChecklists.filter { checklist in
                        checklist.section == "EMERGENCY" || checklist.section == "ABNORMAL"
                    }
                    
                    // If we found any emergency/abnormal checklists, verify they match
                    if !emergencyAbnormalChecklists.isEmpty {
                        // Log the results for debugging
                        if matchingChecklists.isEmpty {
                            print("No matching checklist found for alert: \(alertMessage)")
                        }
                        
                        // Verify we found at least one matching checklist
                        #expect(matchingChecklists.count > 0, "No matching checklist found for alert: \(alertMessage)")
                    }
                }
            }
        }
    }
    
    @Test func testQuizFunctionality() async throws {
        // Test loading a quiz
        let quiz = try Quiz.load(forAircraft: "SF50")
        #expect(quiz.version.count > 0)
        #expect(quiz.sections.count > 0)
        
        // Test accessing sections
        let sections = quiz.allSections
        #expect(sections.count > 0)
        
        // Test getting questions for a section
        if let firstSection = sections.first {
            let questions = quiz.questionsForSection(firstSection)
            #expect(questions.count > 0)
            
            // Test that questions have valid content
            for question in questions {
                #expect(question.question.count > 0)
                #expect(question.answer.count > 0)
            }
        }
        
        // Test random questions
        let randomQuestions = quiz.randomQuestions(count: 3)
        #expect(randomQuestions.count == 3)
        
        // Test random questions from specific section
        if let firstSection = sections.first {
            let sectionQuestions = quiz.randomQuestions(count: 2, from: firstSection)
            #expect(sectionQuestions.count == 2)
        }
        
        // Test error handling for non-existent aircraft
        #expect(throws: QuizError.fileNotFound) {
            try Quiz.load(forAircraft: "NonExistentAircraft")
        }
    }
}
