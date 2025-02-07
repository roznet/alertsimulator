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
    
    var body: some View {
        if self.alertViewModel.flightIsRunning {
            runningView
        }else{
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
        HStack {
            VStack {
                Text("Flight Duration")
                
                HStack(spacing: 0) {
                    // Hours Picker
                    Picker(selection: $alertViewModel.selectedDurationHours, label: Text("Hours")) {
                        ForEach(0..<10) { hour in
                            Text("\(hour)").tag(hour)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 100)
                    .clipped()
                    
                    Text("h")
                        .font(.title)
                        .frame(width: 40)
                    
                    // Minutes Picker
                    Picker(selection: $alertViewModel.selectedDurationMinutes, label: Text("Minutes")) {
                        ForEach(0..<12) { minute in
                            Text("\(minute*5)").tag(minute*5)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 100)
                    .clipped()
                    
                    Text("m")
                        .font(.title)
                        .frame(width: 40)
                }
            }
            Spacer()
            VStack {
                Text("Alert Interval")
                
                HStack(spacing: 0) {
                    // Hours Picker
                    Picker(selection: $alertViewModel.selectedIntervalMinutes, label: Text("Minutes")) {
                        ForEach(self.alertViewModel.intervalChoices, id: \.self) { minutes in
                            Text("\(minutes)").tag(minutes)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 100)
                    .clipped()
                    
                    Text("m")
                        .font(.title)
                        .frame(width: 40)
                    
                }
            }
            
        }
        .padding()
    }
}

#Preview {
    TimerPickerView(alertViewModel: SampleLoader.sampleAlertViewModel())
    TimerPickerView(alertViewModel: SampleLoader.sampleAlertViewModel(running: true))
}
