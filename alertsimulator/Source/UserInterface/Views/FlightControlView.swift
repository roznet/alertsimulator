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

// MARK: - View Components
private struct FlightControlButton: View {
    let title: String
    let action: () -> Void
    let systemImage: String?
    
    init(title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            if let systemImage = systemImage {
                Image(systemName: systemImage)
            } else {
                Text(title)
            }
        }
        .standardButton()
        .padding(.horizontal)
    }
}

private struct FlightStatusButton: View {
    let isRunning: Bool
    let onStart: () -> Void
    let onStop: () -> Void
    
    var body: some View {
        if isRunning {
            FlightControlButton(title: "Stop Flight", action: onStop)
        } else {
            FlightControlButton(title: "Start Flight", action: onStart)
        }
    }
}

private struct ValidationAlert: View {
    let isPresented: Binding<Bool>
    let errors: [AlertViewModel.FlightValidationError]
    let onOpenSettings: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        EmptyView()
            .alert("Invalid Flight Parameters", isPresented: isPresented) {
                if errors.contains(.notificationsNotAuthorized) {
                    Button("Open Settings", role: .none) {
                        onOpenSettings()
                    }
                    Button("Cancel", role: .cancel) {
                        onCancel()
                    }
                } else {
                    Button("OK", role: .cancel) {
                        isPresented.wrappedValue = false
                    }
                }
            } message: {
                Text(errors.map { $0.rawValue }.joined(separator: "\n"))
            }
    }
}

// MARK: - Main View
struct FlightControlView: View {
    @ObservedObject var alertViewModel: AlertViewModel
    @State private var showingValidationAlert = false
    @State private var validationErrors: [AlertViewModel.FlightValidationError] = []
    @State private var showingSettings = false
    
    // MARK: - Actions
    private func startAlerts() {
        alertViewModel.validateFlightParameters { errors in
            self.validationErrors = errors
            if errors.isEmpty {
                self.alertViewModel.startFlight()
            } else {
                self.showingValidationAlert = true
            }
        }
    }
    
    private func stopAlerts() {
        alertViewModel.stopFlight()
    }
    
    private func runOneNow() {
        alertViewModel.generateSingleAlert()
    }
    
    private func openSettings() {
        alertViewModel.openNotificationSettings()
        showingValidationAlert = false
    }
    
    private func cancelValidation() {
        showingValidationAlert = false
        alertViewModel.generateSingleAlert()
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            HStack {
                FlightStatusButton(
                    isRunning: alertViewModel.flightIsRunning,
                    onStart: startAlerts,
                    onStop: stopAlerts
                )
                
                FlightControlButton(title: "Run One Now", action: runOneNow)
                
                FlightControlButton(
                    title: "Settings",
                    systemImage: "gear",
                    action: { showingSettings = true }
                )
            }
            .padding([.trailing, .leading])
        }
        .validationAlert(
            isPresented: $showingValidationAlert,
            errors: validationErrors,
            onOpenSettings: openSettings,
            onCancel: cancelValidation
        )
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

// MARK: - View Modifiers
private extension View {
    func validationAlert(
        isPresented: Binding<Bool>,
        errors: [AlertViewModel.FlightValidationError],
        onOpenSettings: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {
        self.modifier(ValidationAlertModifier(
            isPresented: isPresented,
            errors: errors,
            onOpenSettings: onOpenSettings,
            onCancel: onCancel
        ))
    }
}

private struct ValidationAlertModifier: ViewModifier {
    let isPresented: Binding<Bool>
    let errors: [AlertViewModel.FlightValidationError]
    let onOpenSettings: () -> Void
    let onCancel: () -> Void
    
    func body(content: Content) -> some View {
        content.alert("Invalid Flight Parameters", isPresented: isPresented) {
            if errors.contains(.notificationsNotAuthorized) {
                Button("Open Settings", role: .none) {
                    onOpenSettings()
                }
                Button("Cancel", role: .cancel) {
                    onCancel()
                }
            } else {
                Button("OK", role: .cancel) {
                    isPresented.wrappedValue = false
                }
            }
        } message: {
            Text(errors.map { $0.rawValue }.joined(separator: "\n"))
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @StateObject var alertViewModel: AlertViewModel = AlertViewModel()
    return FlightControlView(alertViewModel: alertViewModel)
}
