import SwiftUI
import Foundation

// Improved version that uses checklists
struct ChecklistView: View {
    let alertMessage: String
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var title: String = ""
    @State private var steps: [(instruction: String, action: String, isConditional: Bool, indentLevel: Int)] = []
    
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
                            ForEach(steps.indices, id: \.self) { index in
                                ChecklistStepView(step: steps[index])
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
            // Load checklist data
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                loadChecklist()
            }
        }
    }
    
    private func loadChecklist() {
        // This is a simplified version with hardcoded data for the most common alerts
        switch alertMessage.uppercased() {
        case "ALT 1":
            title = "Low Alternator 1 Output"
            steps = [
                ("1. ALT 1 Circuit Breaker", "CHECK & SET", false, 0),
                ("2. ALT 1 Switch", "CYCLE", false, 0),
                ("If alternator does not reset:", "", true, 0),
                ("3. ALT 1 Switch", "OFF", false, 1),
                ("4. Non-Essential Bus Loads", "REDUCE", false, 1),
                ("If flight conditions permit, consider shedding the following to preserve Battery 1:", "", true, 1),
                ("Air Conditioning", "", false, 2),
                ("Landing Light", "", false, 2),
                ("Yaw Servo", "", false, 2),
                ("Convenience Power (aux items plugged into armrest jack)", "", false, 2),
                ("EVS Camera (if installed)", "", false, 2),
                ("5. Continue Flight, avoiding IMC or night flight as able (reduced power redundancy).", "", false, 0)
            ]
        case "ALT 2":
            title = "Low Alternator 2 Output"
            steps = [
                ("1. ALT 2 Circuit Breaker", "CHECK & SET", false, 0),
                ("2. ALT 2 Switch", "CYCLE", false, 0),
                ("If alternator does not reset:", "", true, 0),
                ("3. ALT 2 Switch", "OFF", false, 1),
                ("4. Continue Flight, avoiding IMC or night flight as able (reduced power redundancy).", "", false, 0)
            ]
        case "FUEL LOW TOTAL":
            title = "Low Fuel Quantity"
            steps = [
                ("1. Fuel Quantity Gauges", "CHECK", false, 0),
                ("2. Land as soon as practical", "", false, 0)
            ]
        case "OIL PRESS":
            title = "Low Idle Oil Pressure"
            steps = [
                ("1. If pressure is below 10 PSI at idle:", "", true, 0),
                ("Increase RPM to 1000 or higher", "", false, 1),
                ("2. If pressure remains below 30 PSI at higher RPM:", "", true, 0),
                ("Land as soon as practical", "", false, 1),
                ("3. If pressure falls below 10 PSI at higher RPM:", "", true, 0),
                ("Land immediately", "", false, 1)
            ]
        case "ALT AIR OPEN":
            title = "Alternate Air Door Open"
            steps = [
                ("1. Engine Controls", "ADJUST", false, 0),
                ("2. Airspeed", "REDUCE", false, 0),
                ("If alternate air door remains open:", "", true, 0),
                ("3. Anticipate reduced engine performance", "", false, 1)
            ]
        case "FLAP OVERSPEED":
            title = "Flaps Overspeed"
            steps = [
                ("1. Airspeed", "REDUCE", false, 0),
                ("2. Flaps", "RETRACT TO 50% OR 0%", false, 0)
            ]
        default:
            title = ""
            steps = []
        }
        
        isLoading = false
    }
}

struct ChecklistStepView: View {
    let step: (instruction: String, action: String, isConditional: Bool, indentLevel: Int)
    
    var body: some View {
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
        .padding(.vertical, 4)
    }
} 