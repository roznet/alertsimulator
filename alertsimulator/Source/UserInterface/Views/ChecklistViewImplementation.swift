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
        // ABNORMAL CHECKLISTS
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
        case "ANTI ICE HEAT":
            title = "Anti-Ice Heat Failure"
            steps = [
                ("1. Stall warning/AoA heater", "INOPERATIVE", false, 0),
                ("2. If in icing conditions:", "", true, 0),
                ("Exit icing conditions", "", false, 1),
                ("3. Anticipate higher stall speeds", "", false, 0)
            ]
        case "ANTI ICE PRESS":
            title = "Anti-Ice Pressure Issue"
            steps = [
                ("1. Anti-Ice System", "CHECK", false, 0),
                ("2. If in icing conditions:", "", true, 0),
                ("Exit icing conditions", "", false, 1),
                ("3. Anti-Ice Switch", "CYCLE", false, 0),
                ("4. If pressure remains abnormal:", "", true, 0),
                ("Anti-Ice Switch", "OFF", false, 1)
            ]
        case "ANTI ICE SPEED":
            title = "Anti-Ice Speed Warning"
            steps = [
                ("1. Airspeed", "ADJUST", false, 0),
                ("2. If airspeed is too low:", "", true, 0),
                ("Increase airspeed above minimum for ice protection", "", false, 1),
                ("3. If airspeed is too high:", "", true, 0),
                ("Reduce airspeed below maximum for ice protection", "", false, 1)
            ]
        case "AOA FAIL":
            title = "Angle of Attack Failure"
            steps = [
                ("1. AOA/Stall warning system", "INOPERATIVE", false, 0),
                ("2. Anticipate higher stall speeds", "", false, 0),
                ("3. Maintain higher approach speeds", "", false, 0)
            ]
        case "AP MISCOMPARE":
            title = "Autopilot Miscompare"
            steps = [
                ("1. Autopilot", "DISCONNECT", false, 0),
                ("2. Control aircraft manually", "", false, 0),
                ("3. Do not re-engage autopilot", "", false, 0)
            ]
        case "AVIONICS OFF":
            title = "Avionics Master Off"
            steps = [
                ("1. Avionics Master Switch", "ON", false, 0)
            ]
        case "BATT 1":
            title = "Battery 1 Issue"
            steps = [
                ("1. Battery 1 Current", "CHECK", false, 0),
                ("2. If discharge is unexpected:", "", true, 0),
                ("Non-essential electrical loads", "REDUCE", false, 1),
                ("3. Monitor electrical system", "", false, 0)
            ]
        case "PITOT HEAT FAIL":
            title = "Pitot Heat Failure"
            steps = [
                ("1. Pitot Heat Circuit Breaker", "CHECK", false, 0),
                ("2. Pitot Heat Switch", "CYCLE", false, 0),
                ("3. If failure persists:", "", true, 0),
                ("Avoid known icing conditions", "", false, 1)
            ]
        case "PITOT HEAT REQD":
            title = "Pitot Heat Required"
            steps = [
                ("1. Pitot Heat Switch", "ON", false, 0),
                ("2. If in icing conditions:", "", true, 0),
                ("Monitor airspeed indicator for anomalies", "", false, 1)
            ]
        case "START ENGAGED":
            title = "Starter Engaged Warning"
            steps = [
                ("1. Ignition Switch", "DISENGAGE", false, 0),
                ("2. If starter remains engaged:", "", true, 0),
                ("ALT 1 and ALT 2 Switches", "OFF", false, 1),
                ("3. BAT 1 Switch", "OFF", false, 0),
                ("4. Land as soon as practical", "", false, 0)
            ]
            
        // EMERGENCY CHECKLISTS
        case "ENGINE FAILURE":
            title = "Engine Failure In Flight"
            steps = [
                ("1. Best Glide Speed", "ESTABLISH", false, 0),
                ("2. Fuel Selector", "SWITCH TANKS", false, 0),
                ("3. Fuel Pump", "BOOST", false, 0),
                ("4. Mixture", "RICH", false, 0),
                ("5. Ignition Switch", "BOTH", false, 0),
                ("If engine does not restart:", "", true, 0),
                ("6. Perform Emergency Landing Without Power checklist", "", false, 1)
            ]
        case "ENGINE FIRE":
            title = "Engine Fire In Flight"
            steps = [
                ("1. Mixture", "CUTOFF", false, 0),
                ("2. Fuel Selector", "OFF", false, 0),
                ("3. Fuel Pump", "OFF", false, 0),
                ("4. Ignition Switch", "OFF", false, 0),
                ("5. Cabin Heat", "OFF", false, 0),
                ("6. Land immediately", "", false, 0)
            ]
        case "CABIN FIRE":
            title = "Cabin Fire In Flight"
            steps = [
                ("1. BAT 1, ALT 1, and ALT 2 Switches", "OFF, AS REQ'D", false, 0),
                ("2. Fire Extinguisher", "ACTIVATE", false, 0),
                ("3. AVIONICS Switch", "OFF", false, 0),
                ("4. All other switches", "OFF", false, 0),
                ("If setting master switches off eliminated source of fire or fumes and airplane is in night, weather, or IFR conditions:", "", true, 0),
                ("5. Airflow Selector", "OFF", false, 1),
                ("6. BAT 1, BAT 2, ALT 1, and ALT 2 Switches", "ON", false, 1),
                ("7. AVIONICS Switch", "ON", false, 1),
                ("8. Required Systems", "ACTIVATE ONE AT A TIME", false, 1),
                ("9. Temperature Selector", "COLD", false, 1),
                ("10. Vent Selector", "FEET / PANEL / DEFROST POSITION", false, 1),
                ("11. Airflow Selector", "SET AIRFLOW TO MAXIMUM", false, 1),
                ("12. Panel Eyeball Outlets", "OPEN", false, 1),
                ("13. Land as soon as possible", "", false, 0)
            ]
        case "ELECTRICAL FIRE":
            title = "Electrical Fire In Flight"
            steps = [
                ("1. BAT 1, BAT 2, ALT 1, and ALT 2 Switches", "OFF", false, 0),
                ("2. AVIONICS Switch", "OFF", false, 0),
                ("3. All other switches", "OFF", false, 0),
                ("4. Cabin Heat", "OFF", false, 0),
                ("5. Air Vents", "OPEN", false, 0),
                ("If fire goes out:", "", true, 0),
                ("6. Land as soon as practical", "", false, 1),
                ("If fire persists:", "", true, 0),
                ("7. Fire Extinguisher", "ACTIVATE", false, 1),
                ("8. Land immediately", "", false, 1)
            ]
        case "EMERGENCY DESCENT":
            title = "Emergency Descent"
            steps = [
                ("1. Power Lever", "IDLE", false, 0),
                ("2. Mixture", "AS REQUIRED", false, 0),
                ("3. Airspeed", "ESTABLISH VNE", false, 0),
                ("4. Flaps", "UP", false, 0)
            ]
        case "INADVERTENT ICING":
            title = "Inadvertent Icing Encounter"
            steps = [
                ("1. Pitot Heat", "ON", false, 0),
                ("2. Exit icing conditions", "", false, 0),
                ("3. Cabin Heat", "MAXIMUM", false, 0),
                ("4. Windshield Defrost", "ON", false, 0),
                ("5. If ice accumulates:", "", true, 0),
                ("Airspeed", "MAINTAIN HIGHER THAN NORMAL", false, 1),
                ("6. Land as soon as practical", "", false, 0)
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