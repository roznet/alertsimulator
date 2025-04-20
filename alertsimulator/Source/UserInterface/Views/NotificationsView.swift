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
import OSLog

struct NotificationsView: View {
    @ObservedObject var alertViewModel: AlertViewModel
    var body: some View {
        HStack {
            if alertViewModel.hasPendingNotification > 0 {
                VStack {
                    Text("\(alertViewModel.hasPendingNotification) notifications pending")
                    
                    HStack {
                        Text("Next after")
                        Text(alertViewModel.nextAlertTime.formatted(date: .abbreviated, time: .standard))
                    }
                }
            }else{
                Text("No Pending Notification")
            }
            Button(action: {
                self.alertViewModel.checkNotifications()
                
            }) {
                Text( "Check Notifications")
            }
        }
        .onAppear {
            self.alertViewModel.checkNotifications()
            NotificationCenter.default.addObserver(forName: .notificationWereUpdated, object: nil, queue: nil){ _ in
                Task { @MainActor in
                    self.alertViewModel.checkNotifications()
                }
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
    }
}

#Preview {
    @Previewable @StateObject var alertViewModel: AlertViewModel = AlertViewModel()
    
    NotificationsView(alertViewModel: alertViewModel)
}
