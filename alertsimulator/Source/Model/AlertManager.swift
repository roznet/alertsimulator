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

import OSLog

import Foundation

func drawRandomElement<T>(elements: [T], probabilities: [Double]) -> T? {
    // Ensure the input arrays have the same size
    guard elements.count == probabilities.count, !elements.isEmpty else {
        print("Error: Elements and probabilities must have the same non-zero length.")
        return nil
    }
    
    // Normalize probabilities if they don't sum to 1
    let totalProbability = probabilities.reduce(0, +)
    let normalizedProbabilities = probabilities.map { $0 / totalProbability }
    
    // Compute cumulative probabilities
    var cumulativeProbabilities: [Double] = []
    var cumulativeSum = 0.0
    for probability in normalizedProbabilities {
        cumulativeSum += probability
        cumulativeProbabilities.append(cumulativeSum)
    }
    
    // Generate a random number between 0 and 1
    let randomValue = Double.random(in: 0...1)
    
    // Find the corresponding element based on the random value
    for (index, cumulativeProbability) in cumulativeProbabilities.enumerated() {
        if randomValue <= cumulativeProbability {
            return elements[index]
        }
    }
    
    return nil // Should never reach here if probabilities are correct
}

struct AlertManager {
    var available : [FlightAlert]
    var aircraft : Aircraft = Aircraft.defaultValue
    var drawnAlerts: [FlightAlert] = []
    
    init(aircraft : Aircraft = Aircraft.defaultValue) {
        self.aircraft = aircraft
        self.available = FlightAlert.availableFor(aircraft: aircraft)
    }
   
    var sampleAlert: FlightAlert {
        let one = FlightAlert(category: .abnormal, action: .simulate, alertType: .situation, message: "No more fuel", uid: -1)
        return one
    }
    
    private func drawKnowledgeQuestion() -> FlightAlert? {
        // Get all available quiz sections
        let sections = aircraft.quizSections
        guard !sections.isEmpty else { return nil }
        
        // Randomly select a section
        guard let selectedSection = sections.randomElement() else { return nil }
        
        // Get questions from that section
        let questions = aircraft.quizQuestions(for: selectedSection)
        guard questions.count >= 3 else { return nil }
        
        // Randomly select 3 questions
        let selectedQuestions = Array(questions.shuffled().prefix(3))
        
        // Format the submessage with just the questions
        let submessage = selectedQuestions.map { "Q: \($0.question)" }.joined(separator: "\n\n")
        
        return FlightAlert(
            category: .normal,
            action: .review,
            alertType: .situation,
            message: "\(selectedSection) Knowledge Questions",
            uid: -2,
            submessage: submessage,
            aircraftName: aircraft.aircraftName // Special UID for knowledge questions
        )
    }
    
    func nextAlert() -> FlightAlert {
        // First decide if we should draw a knowledge question
        let shouldDrawKnowledgeQuestion = Double.random(in: 0...1) < Settings.shared.knowledgeQuestionProportion
        
        if shouldDrawKnowledgeQuestion {
            // Try to get a knowledge question with the new sophisticated format
            if let knowledgeAlert = drawKnowledgeQuestion() {
                return knowledgeAlert
            }
        }
        
        // If we didn't draw a knowledge question or couldn't get one, draw a regular alert
        return self.drawAlert(alerts: self.available)
    }
    
    func computeProbabilities(alerts : [FlightAlert]) -> [Double] {
        typealias Priority = FlightAlert.Priority
        let categoryCount = Dictionary(grouping: self.available, by: { $0.priority }).mapValues({$0.count})
        let multiplier : [Priority : Double] = [
            .low : Settings.shared.lowPriorityMultiplier,
            .medium : Settings.shared.mediumPriorityMultiplier,
            .high : Settings.shared.highPriorityMultiplier,
            .none : 0.0
        ]
        let total : Double = categoryCount.reduce(0) { $0 + Double($1.value) * (multiplier[$1.key] ?? 0.0)}
        let probabilities : [Double] = alerts.map { (multiplier[$0.priority] ?? 0.0) / total}
        return probabilities
    }
    
    mutating func reset(aircraft : Aircraft? = nil) {
        if let aircraft = aircraft {
            self.aircraft = aircraft
        }
        self.available = FlightAlert.availableFor(aircraft: self.aircraft)
        self.drawnAlerts = []
    }
    
    mutating func drawNextAlert() -> FlightAlert {
        let next = self.nextAlert()
        
        // Only track regular alerts for repeat prevention
        if next.uid != -2 { // Not a knowledge question
            self.drawnAlerts.append(next)
            self.available.removeAll(where: { $0.uniqueIdentifier == next.uniqueIdentifier })
            
            // Use the configured threshold for alert repeats
            if self.drawnAlerts.count > Settings.shared.alertRepeatThreshold {
                let first = self.drawnAlerts.removeFirst()
                self.available.append(first)
            }
        }
        
        return next
    }
    
    func drawAlert(alerts : [FlightAlert]) -> FlightAlert {
        let probabilities = self.computeProbabilities(alerts: alerts)
        let next = drawRandomElement(elements: alerts, probabilities: probabilities)
        return next ?? self.sampleAlert
    }
}
