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
    @State private var selectedHours = 0
    @State private var selectedMinutes = 0
    
    var body: some View {
        VStack {
            Text("Set Timer")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 20)
            
            HStack(spacing: 0) {
                // Hours Picker
                Picker(selection: $selectedHours, label: Text("Hours")) {
                    ForEach(0..<24) { hour in
                        Text("\(hour)").tag(hour)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 100, height: 200)
                .clipped()
                
                Text("h")
                    .font(.title)
                    .bold()
                    .frame(width: 40)
                
                // Minutes Picker
                Picker(selection: $selectedMinutes, label: Text("Minutes")) {
                    ForEach(0..<60) { minute in
                        Text("\(minute)").tag(minute)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 100, height: 200)
                .clipped()
                
                Text("m")
                    .font(.title)
                    .bold()
                    .frame(width: 40)
            }
            
            Spacer()
            
            Text("Selected Duration: \(selectedHours) hours \(selectedMinutes) minutes")
                .font(.headline)
                .padding(.top, 20)
        }
        .padding()
    }
}

struct TimerPickerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerPickerView()
    }
}
