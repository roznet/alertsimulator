import Foundation

struct QuizQuestion: Codable, Identifiable, Hashable {
    let id = UUID()
    let question: String
    let answer: String
    
    private enum CodingKeys: String, CodingKey {
        case question, answer
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(question)
        hasher.combine(answer)
    }
    
    static func == (lhs: QuizQuestion, rhs: QuizQuestion) -> Bool {
        return lhs.question == rhs.question && lhs.answer == rhs.answer
    }
}

struct QuizSection: Codable {
    let questions: [QuizQuestion]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        questions = try container.decode([QuizQuestion].self)
    }
}

struct Quiz: Codable {
    let version: String
    let sections: [String: QuizSection]
    
    static func load(forAircraft aircraftName: String) throws -> Quiz {
        let fileName = "\(aircraftName)-Quiz"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw QuizError.fileNotFound
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(Quiz.self, from: data)
    }
    
    func questionsForSection(_ section: String) -> [QuizQuestion] {
        return sections[section]?.questions ?? []
    }
    
    var allSections: [String] {
        return Array(sections.keys).sorted()
    }
    
    func randomQuestions(count: Int, from section: String? = nil) -> [QuizQuestion] {
        let availableQuestions: [QuizQuestion]
        if let section = section {
            availableQuestions = sections[section]?.questions ?? []
        } else {
            availableQuestions = sections.values.flatMap { $0.questions }
        }
        
        // If count is greater than available questions, return all questions in random order
        if count >= availableQuestions.count {
            return availableQuestions.shuffled()
        }
        
        // Otherwise, pick 'count' random questions
        var questions: Set<QuizQuestion> = []
        while questions.count < count {
            if let question = availableQuestions.randomElement() {
                questions.insert(question)
            }
        }
        return Array(questions)
    }
}

enum QuizError: Error {
    case fileNotFound
    case decodingError
} 