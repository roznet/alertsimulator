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
    func nextAlert() -> FlightAlert {
        self.available.randomElement() ?? self.sampleAlert
    }
    
    func computeProbabilities(alerts : [FlightAlert]) -> [Double] {
        typealias Priority = FlightAlert.Priority
        let categoryCount = Dictionary(grouping: self.available, by: { $0.priority }).mapValues({$0.count})
        let multiplier : [Priority : Double] = [
            .low : 1.0,
            .medium : 5.0,
            .high : 10.0,
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
        let next = self.drawAlert(alerts: self.available)
        self.drawnAlerts.append(next)
        self.available.removeAll(where: { $0.uniqueIdentifier == next.uniqueIdentifier })
        if self.drawnAlerts.count > 5 {
            let first = self.drawnAlerts.removeFirst()
            self.available.append(first)
        }
        return next
    }
    func drawAlert(alerts : [FlightAlert]) -> FlightAlert{
        let probabilities = self.computeProbabilities(alerts: alerts)
        let next = drawRandomElement(elements: alerts, probabilities: probabilities)
        return next ?? self.sampleAlert
    }
}
