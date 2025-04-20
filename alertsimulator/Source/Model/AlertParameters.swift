import Foundation

struct AlertParameters : Hashable, Codable {
    var knowledgeQuestionProportion: Double
    var alertRepeatThreshold: Int
    var highPriorityMultiplier: Double
    var mediumPriorityMultiplier: Double
    var lowPriorityMultiplier: Double
    var randomOffsetRange : Double
    
    init(
        knowledgeQuestionProportion: Double = 0.0,
        alertRepeatThreshold: Int = 3,
        highPriorityMultiplier: Double = 10.0,
        mediumPriorityMultiplier: Double = 5.0,
        lowPriorityMultiplier: Double = 1.0,
        randomOffsetRange: Double = 0.0
    ) {
        self.knowledgeQuestionProportion = knowledgeQuestionProportion
        self.alertRepeatThreshold = alertRepeatThreshold
        self.highPriorityMultiplier = highPriorityMultiplier
        self.mediumPriorityMultiplier = mediumPriorityMultiplier
        self.lowPriorityMultiplier = lowPriorityMultiplier
        self.randomOffsetRange = randomOffsetRange
    }
} 
