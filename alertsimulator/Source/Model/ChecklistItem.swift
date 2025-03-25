import Foundation

struct ChecklistItem: Codable, Identifiable {
    let id: String = UUID().uuidString
    let instruction: String
    let action: String
    let isConditional: Bool
    let indentLevel: Int
    let stepNumber: String?
    let subSteps: [ChecklistItem]
    
    enum CodingKeys: String, CodingKey {
        case instruction
        case action
        case isConditional = "is_conditional"
        case indentLevel = "indent_level"
        case stepNumber = "step_number"
        case subSteps = "sub_steps"
    }
} 
