import SwiftUI
import Foundation

// Improved version that uses checklists
struct ChecklistView: View {
    let alertMessage: String
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var title: String = ""
    @State private var steps: [ChecklistItem] = []
    @ObservedObject var alertViewModel: AlertViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("Checklist")
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title2)
                }
                .padding()
            }
            
            if isLoading {
                ProgressView()
                    .padding()
            } else if !steps.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text(title)
                        .font(.title)
                        .padding(.horizontal)
                    
                    Text(alertMessage)
                        .font(.title2)
                        .foregroundColor(.yellow)
                        .padding(.horizontal)
                    
                    Divider()
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(steps) { step in
                                ChecklistStepView(step: step)
                            }
                        }
                        .padding()
                    }
                }
            } else {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.yellow)
                        .padding()
                    
                    Text("No checklist available for this alert")
                        .font(.headline)
                    
                    Text("Alert: \(alertMessage)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            loadChecklist()
        }
    }
    
    private func loadChecklist() {
        // Find the matching checklist using the view model
        if let checklist = alertViewModel.findChecklist(for: alertMessage) {
            title = checklist.title
            steps = checklist.steps
        }
        isLoading = false
    }
}

struct ChecklistStepView: View {
    let step: ChecklistItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                // Indentation based on level
                if step.indentLevel > 0 {
                    ForEach(0..<step.indentLevel, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 2)
                            .padding(.horizontal, 8)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    if step.isConditional {
                        Text(step.instruction)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                    } else {
                        HStack(alignment: .top) {
                            Text(step.instruction)
                                .font(.body)
                            
                            Spacer()
                            
                            if !step.action.isEmpty {
                                Text(step.action)
                                    .font(.body)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
            }
            
            if !step.subSteps.isEmpty {
                ForEach(step.subSteps) { subStep in
                    ChecklistStepView(step: subStep)
                        .padding(.leading)
                }
            }
        }
        .padding(.vertical, 4)
    }
} 
