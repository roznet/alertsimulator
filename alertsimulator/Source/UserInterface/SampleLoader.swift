//  MIT License
//
//  Created on 04/01/2025 for alertsimulator
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

struct SampleLoader {
    static func sampleCAS(category : CASMessage.Category, type : FlightAlert.AlertType = .cas) -> [CASMessage] {
        let available = FlightAlert.availableFor(aircraft: FlightAlert.aircrafts.first!)
        var samples: [CASMessage] = []
        
        for alert in available {
            if alert.category == category && alert.alertType == type{
                samples.append(alert.casMessage)
            }
        }
        
        return samples
    }
    
    static func sampleTrackedAlert(n : Int, interval : TimeInterval = 10.0) -> [TrackedAlert]{
        let minute = 60.0
        let alerts = FlightAlert.availableFor(aircraft: FlightAlert.aircrafts.first!)
        let sampleAlerts : [TrackedAlert] = [
            TrackedAlert(date: Date().addingTimeInterval(interval*minute), alert: alerts.first!)
        ]
        return sampleAlerts
    }
    
    static func sampleRunningFlight(trackedAlertsCount : Int = 0) -> Flight{
        let minute = 60.0
        let sampleAlerts : [TrackedAlert] = trackedAlertsCount > 0 ? self.sampleTrackedAlert(n: trackedAlertsCount) : []
        let flight = Flight(aircraft: Aircraft.defaultValue, duration: 60*minute, interval: 10*minute, start: Date().addingTimeInterval(-5*minute), protectedStart: nil, protectedEnd: nil, flightAlerts: sampleAlerts)
        return flight
    }
    
    
    static func sampleAlertViewModel(running: Bool = false) -> AlertViewModel {
        let viewModel = AlertViewModel()
        viewModel.flight = SampleLoader.sampleRunningFlight(trackedAlertsCount: running ? 4 : 0)
        viewModel.updateFromFlight()
        return viewModel
    }
}

