//  MIT License
//
//  Created on 12/01/2025 for alertsimulator
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


struct AircraftView: View {
    @ObservedObject var alertViewModel: AlertViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            Menu {
                ForEach(alertViewModel.availableAircraftNames, id: \.self) { aircraft in
                    Button(action: {
                        alertViewModel.selectedAircraftName = aircraft
                        alertViewModel.updateAircraft()
                    }) {
                        HStack {
                            Text(aircraft)
                            if aircraft == alertViewModel.selectedAircraftName {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "airplane")
                        .foregroundColor(.primary)
                    Text(alertViewModel.selectedAircraftName)
                        .lineLimit(1)
                        .foregroundColor(.accentColor)
                }
            }
            
            if alertViewModel.numberOfAlertForAircraft > 0 {
                HStack(spacing: 4) {
                    Text("\(alertViewModel.numberOfAlertForAircraft)")
                        .fontWeight(.medium)
                    Text("alerts")
                }
                .font(.caption)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.blue.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            if alertViewModel.numberOfKnowledgeQuestionsForAircraft > 0 {
                HStack(spacing: 4) {
                    Text("\(alertViewModel.numberOfKnowledgeQuestionsForAircraft)")
                        .fontWeight(.medium)
                    Text("questions")
                }
                .font(.caption)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.green.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    @Previewable @StateObject var alertViewModel: AlertViewModel = AlertViewModel()
    AircraftView(alertViewModel: alertViewModel)
}

