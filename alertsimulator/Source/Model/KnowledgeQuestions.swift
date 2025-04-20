import Foundation

struct KnowledgeQuestion: Codable, Identifiable, Hashable {
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
    
    static func == (lhs: KnowledgeQuestion, rhs: KnowledgeQuestion) -> Bool {
        return lhs.question == rhs.question && lhs.answer == rhs.answer
    }
}

struct KnowledgeQuestionSection: Codable {
    let questions: [KnowledgeQuestion]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        questions = try container.decode([KnowledgeQuestion].self)
    }
}

struct KnowledgeQuestions: Codable {
    let version: String
    let sections: [String: KnowledgeQuestionSection]
    
    static func load(forAircraft aircraftName: String) throws -> KnowledgeQuestions {
        let fileName = "\(aircraftName)-Quiz"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw KnowledgeQuestionError.fileNotFound
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(KnowledgeQuestions.self, from: data)
    }
    
    func questionsForSection(_ section: String) -> [KnowledgeQuestion] {
        return sections[section]?.questions ?? []
    }
    
    var knowledgeQuestionsCount : Int {
        return sections.values.reduce(0) {$0 + $1.questions.count}
    }
    
    var allSections: [String] {
        return Array(sections.keys).sorted()
    }
    
    func randomQuestions(count: Int, from section: String? = nil) -> [KnowledgeQuestion] {
        let availableQuestions: [KnowledgeQuestion]
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
        var questions: Set<KnowledgeQuestion> = []
        while questions.count < count {
            if let question = availableQuestions.randomElement() {
                questions.insert(question)
            }
        }
        return Array(questions)
    }
    
    func findAnswers(for questionsText: String) -> [String] {
        // Split the text into lines and extract questions
        let lines = questionsText.components(separatedBy: .newlines)
        let questions = lines.compactMap { line -> String? in
            if line.hasPrefix("Q: ") {
                return String(line.dropFirst(3))
            }
            return nil
        }
        
        // Find answers for each question
        return questions.compactMap { questionText -> String? in
            // Search through all sections for a matching question
            for section in sections.values {
                if let matchingQuestion = section.questions.first(where: { $0.question == questionText }) {
                    return matchingQuestion.answer
                }
            }
            return nil
        }
    }
}

enum KnowledgeQuestionError: Error {
    case fileNotFound
    case decodingError
} 
