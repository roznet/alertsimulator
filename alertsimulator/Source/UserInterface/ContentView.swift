///  MIT License
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

struct ContentView: View {
    @StateObject var alertViewModel: AlertViewModel = .init()
    var body: some View {
        VStack {
            Text("Configure Flight Alerts")
                .font(.largeTitle)
                .bold()
            TimerPickerView(alertViewModel: alertViewModel)
            HStack {
                Button(action: {
                    AlertSimulatorApp.notificationManager.cancelAll()
                }) {
                    Text("Cancel All Alert")
                }
                Spacer()
                Button(action: {
                    let alert = AlertSimulatorApp.alertManager.drawNextAlert()
                    AlertSimulatorApp.notificationManager.startNext(alert: alert)
                }) {
                    Text("Schedule Alert")
                }
                .standardButton()
                .padding()
                Button(action: {
                    let alert = AlertSimulatorApp.alertManager.drawNextAlert()
                    AlertSimulatorApp.notificationManager.scheduleNext(alert: alert, delay: 3.0)
                    
                }) {
                    Text("Run One Now")
                }
                .standardButton()
            }
        }
        .padding()
        GeometryReader { geometry in
            VStack {
                Spacer()
                VStack {
                    CASView(casMessage: $alertViewModel.casMessage.wrappedValue)
                }
                .frame(height: geometry.size.height / 3)
                .frame(maxWidth: .infinity)
                .background(Color.brown)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
        }
    }
}

#Preview {
    ContentView()
}
