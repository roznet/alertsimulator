//  MIT License
//
//  Created on 10/01/2025 for alertsimulator
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

struct FlightControlView : View {
    @ObservedObject var alertViewModel: AlertViewModel
    @State private var showingValidationAlert = false
    @State private var validationErrors: [AlertViewModel.FlightValidationError] = []
    
    func startAlerts() {
        alertViewModel.validateFlightParameters { errors in
            self.validationErrors = errors
            if errors.isEmpty {
                self.alertViewModel.startFlight()
            } else {
                self.showingValidationAlert = true
            }
        }
    }
    
    func stopAlerts() {
        self.alertViewModel.stopFlight()
    }
    
    func runOneNow() {
        alertViewModel.generateSingleAlert()
    }
    
    var body: some View {
        HStack {
            if alertViewModel.flightIsRunning {
                Button(action: {
                    self.stopAlerts()
                }) {
                    Text("Stop Flight")
                }
                .standardButton()
                .padding()
            } else {
                Button(action: {
                    self.startAlerts()
                }) {
                    Text("Start Flight")
                }
                .standardButton()
                .padding()
            }
            
            Button(action: {
                self.runOneNow()
            }) {
                Text("Run One Now")
            }
            .standardButton()
        }
        .padding([.trailing, .leading])
        .alert("Invalid Flight Parameters", isPresented: $showingValidationAlert) {
            if validationErrors.contains(.notificationsNotAuthorized) {
                Button("Open Settings", role: .none) {
                    alertViewModel.openNotificationSettings()
                    showingValidationAlert = false
                }
                Button("Cancel", role: .cancel) {
                    showingValidationAlert = false
                    self.alertViewModel.generateSingleAlert()
                }
            } else {
                Button("OK", role: .cancel) {
                    showingValidationAlert = false
                }
            }
        } message: {
            Text(validationErrors.map { $0.rawValue }.joined(separator: "\n"))
        }
    }
}

#Preview {
    @Previewable @StateObject var alertViewModel: AlertViewModel = AlertViewModel()
    FlightControlView(alertViewModel: alertViewModel)
}
