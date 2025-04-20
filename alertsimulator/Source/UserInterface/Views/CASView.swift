//  MIT License
//
//  Created on 04/01/2025 for alertsimulator
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
import RZUtilsSwift

// MARK: - View Model
class CASViewModel : ObservableObject {
    typealias CCategory = CASMessage.Category
    @Published var category: CCategory
    @Published var message: String
    @Published var submessage: String
    
    init(casMessage: CASMessage) {
        self.message = casMessage.message
        self.submessage = casMessage.submessage
        self.category = casMessage.category
    }
}

// MARK: - View Components
private struct EyeButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "eye.fill")
                .foregroundColor(.white)
                .padding(8)
        }
        .background(Color.blue.opacity(0.6))
        .clipShape(Circle())
        .padding(.leading, 8)
    }
}

private struct MessageHeader: View {
    let message: String
    let category: CASMessage.Category
    let onChecklistTapped: () -> Void
    let onKnowledgeQuestionTapped: () -> Void
    let alertViewModel: AlertViewModel
    let isKnowledgeQuestion: Bool
    
    var body: some View {
        HStack {
            Spacer()
            if alertViewModel.hasChecklist {
                EyeButton(action: onChecklistTapped)
            }
            if isKnowledgeQuestion {
                Button(action: onKnowledgeQuestionTapped) {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(.white)
                        .padding(8)
                }
                .background(Color.green.opacity(0.6))
                .clipShape(Circle())
                .padding(.leading, 8)
            }
            
            Text(message)
                .casMessage(category: category)
            
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding([.bottom, .top])
    }
}

private struct AlertsSection: View {
    let submessage: String
    let category: CASMessage.Category
    let onChecklistTapped: () -> Void
    let onKnowledgeQuestionTapped: () -> Void
    let alertViewModel: AlertViewModel
    let isKnowledgeQuestion: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Alerts")
                    .foregroundColor(.white)
                
                Spacer()
                
                if alertViewModel.hasChecklist {
                    Button(action: onChecklistTapped) {
                        HStack(spacing: 4) {
                            Image(systemName: "list.bullet.clipboard")
                            Text("View Checklist")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    }
                    .background(Color.blue.opacity(0.6))
                    .cornerRadius(4)
                }
                
                if isKnowledgeQuestion {
                    Button(action: onKnowledgeQuestionTapped) {
                        HStack(spacing: 4) {
                            Image(systemName: "questionmark.circle")
                            Text("View Answers")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    }
                    .background(Color.green.opacity(0.6))
                    .cornerRadius(4)
                }
            }
            
            Divider()
                .background(Color.white)
                .padding([.bottom])
            
            if !submessage.isEmpty {
                Text(submessage)
                    .casSubMessage(category: category)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(.black)
        .frame(maxWidth: 600, alignment: .trailing)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 1))
        .padding([.leading, .top, .bottom])
    }
}

// MARK: - Main View
struct CASView: View {
    @Binding var casMessage: CASMessage
    @State private var showingChecklist = false
    @State private var showingKnowledgeQuestions = false
    @ObservedObject var alertViewModel: AlertViewModel
    
    var isKnowledgeQuestion: Bool {
        return casMessage.message.contains("Knowledge Questions")
    }
    
    var body: some View {
        VStack(alignment: .trailing) {
            if !casMessage.message.isEmpty {
                MessageHeader(
                    message: casMessage.message,
                    category: casMessage.category,
                    onChecklistTapped: { showingChecklist = true },
                    onKnowledgeQuestionTapped: { showingKnowledgeQuestions = true },
                    alertViewModel: alertViewModel,
                    isKnowledgeQuestion: isKnowledgeQuestion
                )
            }
            
            Spacer()
            
            HStack {
                Spacer()
                AlertsSection(
                    submessage: casMessage.submessage,
                    category: casMessage.category,
                    onChecklistTapped: { showingChecklist = true },
                    onKnowledgeQuestionTapped: { showingKnowledgeQuestions = true },
                    alertViewModel: alertViewModel,
                    isKnowledgeQuestion: isKnowledgeQuestion
                )
            }
            
            Text(casMessage.categoryDescription)
                .casAnnuciation(category: casMessage.category)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .background(Color.black)
        }
        .background(Color.brown)
        .sheet(isPresented: $showingChecklist) {
            if !casMessage.message.isEmpty {
                ChecklistView(alertMessage: casMessage.message, alertViewModel: self.alertViewModel)
            }
        }
        .sheet(isPresented: $showingKnowledgeQuestions) {
            let answers = alertViewModel.findAnswers(for: casMessage.submessage)
            KnowledgeQuestionView(questionsText: casMessage.submessage, answers: answers)
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @StateObject var alertViewModel: AlertViewModel = AlertViewModel()
    @Previewable @State var casMessage1: CASMessage = SampleLoader.sampleCAS(category: .abnormal).first!
    @Previewable @State var casMessage2: CASMessage = SampleLoader.sampleCAS(category: .emergency).first!
    @Previewable @State var casMessage3: CASMessage = CASMessage()
    @Previewable @State var casMessage4: CASMessage = SampleLoader.sampleCAS(category: .abnormal, type:.situation).first!
    
    VStack {
        CASView(casMessage: $casMessage1, alertViewModel: alertViewModel)
            .padding(.bottom)
        CASView(casMessage: $casMessage2, alertViewModel: alertViewModel)
            .padding(.bottom)
        CASView(casMessage: $casMessage3, alertViewModel: alertViewModel)
            .padding(.bottom)
        CASView(casMessage: $casMessage4, alertViewModel: alertViewModel)
            .padding(.bottom)
    }
}
