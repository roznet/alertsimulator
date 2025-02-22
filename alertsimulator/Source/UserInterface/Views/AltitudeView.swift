//  MIT License
//
//  Created on 15/02/2025 for alertsimulator
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

import SwiftUI

struct AltitudeData {
    var altitude: Double
    var selectedAltitude: Double
    var barometricPressure: Double
}

struct AltitudeIndicatorView: View {
    let data: AltitudeData
    let minAltitude: Double = 0
    let maxAltitude: Double = 50000 // Adjust as needed
    let step: Double = 100 // Altitude tick marks spacing
    
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let scaleFactor = height / 1000 // Adjust scrolling effect
            let yOffset = CGFloat(data.altitude.truncatingRemainder(dividingBy: step)) * scaleFactor
            
            ZStack {
                VStack(spacing: 0) {
                    ForEach(stride(from: data.altitude - 500, to: data.altitude + 500, by: step).reversed(), id: \.self) { value in
                        Text("\(Int(value))")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(height: 40)
                            .background(Color.clear)
                    }
                }
                .offset(y: yOffset)
                
                // Indicated Altitude
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 80, height: 40)
                    .overlay(
                        Text("\(Int(data.altitude))")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    )
                    .offset(y: 0)
                    
                // Selected Altitude
                VStack {
                    Text("\(Int(data.selectedAltitude))")
                        .font(.title3)
                        .foregroundColor(.cyan)
                        .padding(5)
                        .background(Color.black.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .top)
                
                // Barometric Pressure
                VStack {
                    Spacer()
                    Text("\(String(format: "%.2f", data.barometricPressure)) IN")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(5)
                        .background(Color.black.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
            }
            .frame(width: 100, height: height)
            .background(LinearGradient(colors: [.blue, .brown], startPoint: .top, endPoint: .bottom))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

// Preview
struct AltitudeIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        AltitudeIndicatorView(data: AltitudeData(altitude: 9000, selectedAltitude: 10000, barometricPressure: 29.92))
            .frame(width: 100, height: 300)
            .background(Color.black)
    }
}
