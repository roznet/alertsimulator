import Foundation

enum ChecklistError: Error {
    case fileNotFound
    case decodingError
}

struct Checklist: Codable, Identifiable {
    let id: String
    let title: String
    let section: String
    let subsection: String?
    let alert: String?
    let alertType: String?
    let alertMessage: String?
    let steps: [ChecklistItem]
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case section
        case subsection
        case alert
        case alertType = "alert_type"
        case alertMessage = "alert_message"
        case steps
    }
    
    static func loadFromJSON() throws -> [Checklist] {
        guard let url = Bundle.main.url(forResource: "SR22TG6-Checklists", withExtension: "json") else {
            throw ChecklistError.fileNotFound
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode([Checklist].self, from: data)
    }
} 
