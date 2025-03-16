//  MIT License
//
//  Created on 28/12/2024 for alertsimulator
//
//  Copyright (c) 2024 Brice Rosenzweig
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
import SwiftUI

struct TimerPickerView: View {
    @ObservedObject var alertViewModel: AlertViewModel
    
    // Computed property to get total duration in minutes
    private var totalDurationMinutes: Int {
        alertViewModel.selectedDurationHours * 60 + alertViewModel.selectedDurationMinutes
    }
    
    // Binding for total duration that updates hours and minutes
    private var durationBinding: Binding<Double> {
        Binding<Double>(
            get: { Double(totalDurationMinutes) },
            set: { newValue in
                let minutes = Int(round(newValue))
                alertViewModel.selectedDurationHours = minutes / 60
                alertViewModel.selectedDurationMinutes = minutes % 60
                // Ensure interval doesn't exceed new duration
                if alertViewModel.selectedIntervalMinutes > minutes {
                    alertViewModel.selectedIntervalMinutes = minutes
                }
            }
        )
    }
    
    // Binding for interval that handles conversion between Double and Int
    private var intervalBinding: Binding<Double> {
        Binding<Double>(
            get: { Double(alertViewModel.selectedIntervalMinutes) },
            set: { newValue in
                let minutes = Int(round(newValue))
                let maxInterval = min(totalDurationMinutes, max(1, minutes))
                alertViewModel.selectedIntervalMinutes = maxInterval
            }
        )
    }
    
    var body: some View {
        if self.alertViewModel.flightIsRunning {
            runningView
        } else {
            setupView
        }
    }
    
    var runningView: some View {
        HStack {
            VStack {
                Text("Flight Duration")
                Text("\(alertViewModel.selectedDurationHours) h \(alertViewModel.selectedDurationMinutes) m")
            }
            VStack {
                Text("Alert Interval")
                Text("\(alertViewModel.selectedIntervalMinutes) m")
            }
            VStack {
                Text("Flight Ends")
                Text(alertViewModel.flight.end.formatted(date: .omitted, time: .standard))
            }
        }
    }
    
    var setupView: some View {
        VStack(spacing: 20) {
            // Flight Duration Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Flight Duration")
                    .font(.headline)
                
                HStack {
                    Slider(value: durationBinding, in: 5...600, step: 5)
                    Text("\(totalDurationMinutes / 60)h \(totalDurationMinutes % 60)m")
                        .frame(width: 70, alignment: .trailing)
                        .monospacedDigit()
                }
                Text("5 minutes to 10 hours")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            // Alert Interval Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Alert Interval")
                    .font(.headline)
                
                let maxInterval = max(1.0, Double(totalDurationMinutes))
                HStack {
                    // Use a fixed range slider and scale the values
                    Slider(
                        value: Binding(
                            get: { intervalBinding.wrappedValue / maxInterval },
                            set: { intervalBinding.wrappedValue = $0 * maxInterval }
                        ),
                        in: 0...1,
                        step: 1.0 / maxInterval
                    )
                    Text("\(alertViewModel.selectedIntervalMinutes)m")
                        .frame(width: 50, alignment: .trailing)
                        .monospacedDigit()
                }
                Text("1 minute to flight duration")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

#Preview {
    TimerPickerView(alertViewModel: SampleLoader.sampleAlertViewModel())
    TimerPickerView(alertViewModel: SampleLoader.sampleAlertViewModel(running: true))
}
