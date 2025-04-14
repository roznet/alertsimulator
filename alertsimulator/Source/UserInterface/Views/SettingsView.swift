import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var alertRepeatThreshold: Double
    @State private var highPriorityMultiplier: Double
    @State private var mediumPriorityMultiplier: Double
    @State private var lowPriorityMultiplier: Double
    @State private var knowledgeQuestionProportion: Double
    @State private var showHelp: Bool = false
    
    // Add default values as static constants
    private static let defaultAlertRepeatThreshold: Double = 5
    private static let defaultHighPriorityMultiplier: Double = 10.0
    private static let defaultMediumPriorityMultiplier: Double = 5.0
    private static let defaultLowPriorityMultiplier: Double = 1.0
    private static let defaultKnowledgeQuestionProportion: Double = 0.0
    
    init() {
        _alertRepeatThreshold = State(initialValue: Double(Settings.shared.alertRepeatThreshold))
        _highPriorityMultiplier = State(initialValue: Settings.shared.highPriorityMultiplier)
        _mediumPriorityMultiplier = State(initialValue: Settings.shared.mediumPriorityMultiplier)
        _lowPriorityMultiplier = State(initialValue: Settings.shared.lowPriorityMultiplier)
        _knowledgeQuestionProportion = State(initialValue: Settings.shared.knowledgeQuestionProportion)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Alert Repeat Prevention")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Minimum alerts before repeat")
                        HStack {
                            Slider(value: $alertRepeatThreshold, in: 1...20, step: 1)
                            Text("\(Int(alertRepeatThreshold))")
                        }
                        if showHelp {
                            Text("Controls how many different alerts must be shown before an alert can be repeated. Higher values ensure more variety but may exhaust available alerts for the aircraft type.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("Priority Weights")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("High Priority Multiplier")
                        HStack {
                            Slider(value: $highPriorityMultiplier, in: 1...20)
                            Text(String(format: "%.1f", highPriorityMultiplier))
                        }
                        
                        Text("Medium Priority Multiplier")
                        HStack {
                            Slider(value: $mediumPriorityMultiplier, in: 1...10)
                            Text(String(format: "%.1f", mediumPriorityMultiplier))
                        }
                        
                        Text("Low Priority Multiplier")
                        HStack {
                            Slider(value: $lowPriorityMultiplier, in: 0.0...5)
                            Text(String(format: "%.1f", lowPriorityMultiplier))
                        }
                        
                        if showHelp {
                            Text("Adjusts the relative frequency of different alert priorities. Higher multipliers increase the likelihood of that priority being selected. For example, setting High to 10.0 makes high-priority alerts ten times more likely than a multiplier of 1.0.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("Knowledge Questions")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Knowledge Question Proportion")
                        HStack {
                            Slider(value: $knowledgeQuestionProportion, in: 0...1, step: 0.05)
                            Text("\(Int(knowledgeQuestionProportion * 100))%")
                        }
                        if showHelp {
                            Text("Controls the proportion of knowledge questions versus regular alerts. For example, setting to 20% means that 20% of the alerts will be knowledge questions and 80% will be regular alerts.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Alert Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .principal) {
                    HStack {
                        Button(action: {
                            showHelp.toggle()
                        }) {
                            Image(systemName: showHelp ? "questionmark.circle.fill" : "questionmark.circle")
                        }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    HStack(spacing: 16) {
                        Button("Reset") {
                            resetToDefaults()
                        }
                        .foregroundColor(.red)
                        
                        Button("Save") {
                            saveSettings()
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    private func resetToDefaults() {
        alertRepeatThreshold = Self.defaultAlertRepeatThreshold
        highPriorityMultiplier = Self.defaultHighPriorityMultiplier
        mediumPriorityMultiplier = Self.defaultMediumPriorityMultiplier
        lowPriorityMultiplier = Self.defaultLowPriorityMultiplier
        knowledgeQuestionProportion = Self.defaultKnowledgeQuestionProportion
    }
    
    private func saveSettings() {
        Settings.shared.alertRepeatThreshold = Int(alertRepeatThreshold)
        Settings.shared.highPriorityMultiplier = highPriorityMultiplier
        Settings.shared.mediumPriorityMultiplier = mediumPriorityMultiplier
        Settings.shared.lowPriorityMultiplier = lowPriorityMultiplier
        Settings.shared.knowledgeQuestionProportion = knowledgeQuestionProportion
    }
}

#Preview {
    SettingsView()
} 
