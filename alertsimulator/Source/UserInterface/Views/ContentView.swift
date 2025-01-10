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
import OSLog

struct ContentView: View {
    @StateObject var alertViewModel: AlertViewModel = .init()
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Configure Flight Alerts")
                    .font(.largeTitle)
                    .bold()
                TimerPickerView(alertViewModel: alertViewModel)
                NotificationsView(alertViewModel: self.alertViewModel)
                FlightControlView(alertViewModel: self.alertViewModel)
                Spacer()
                VStack {
                    HStack() {
                        Spacer()
                        Button(action: {
                            self.alertViewModel.clearAlerts()
                        }) {
                            Text("Clear Alerts")
                        }
                        .casButton()
                    }
                    CASView(casMessage: $alertViewModel.casMessage)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(height: geometry.size.height / 3)
                .background(Color.brown)
                //.edgesIgnoringSafeArea(.all)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(){
            self.alertViewModel.fromSettings()
        }
        .onDisappear {
            self.alertViewModel.toSettings()
        }
    }
}

#Preview {
    ContentView()
}
