import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var alertRepeatThreshold: Double
    @State private var highPriorityMultiplier: Double
    @State private var mediumPriorityMultiplier: Double
    @State private var lowPriorityMultiplier: Double
    @State private var showHelp: Bool = false
    
    init() {
        _alertRepeatThreshold = State(initialValue: Double(Settings.shared.alertRepeatThreshold))
        _highPriorityMultiplier = State(initialValue: Settings.shared.highPriorityMultiplier)
        _mediumPriorityMultiplier = State(initialValue: Settings.shared.mediumPriorityMultiplier)
        _lowPriorityMultiplier = State(initialValue: Settings.shared.lowPriorityMultiplier)
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
                    Button("Save") {
                        saveSettings()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveSettings() {
        Settings.shared.alertRepeatThreshold = Int(alertRepeatThreshold)
        Settings.shared.highPriorityMultiplier = highPriorityMultiplier
        Settings.shared.mediumPriorityMultiplier = mediumPriorityMultiplier
        Settings.shared.lowPriorityMultiplier = lowPriorityMultiplier
    }
}

#Preview {
    SettingsView()
} 
