//  MIT License
//
//  Created on 18/01/2025 for alertsimulator
//
//  Copyright (c) 2025 Brice Rosenzweig
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation


struct Aircraft : Hashable, Equatable{
    static let defaultValue : Aircraft = Aircraft(aircraftName: "S22TG6")
    let aircraftName : String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(aircraftName)
    }
    static func == (lhs: Aircraft, rhs: Aircraft) -> Bool {
        return lhs.aircraftName == rhs.aircraftName
    }
    
    var alerts : [FlightAlert] {
        return FlightAlert.availableFor(aircraft: self)
    }
    
    var checklists : [Checklist] {
        guard let checklists = try? Checklist.load(for: self) else {
            return []
        }
        return checklists
    }
    
    var knowledgeQuestions: KnowledgeQuestions? {
        return try? KnowledgeQuestions.load(forAircraft: self.aircraftName)
    }
    
    func randomKnowledgeQuestions(count: Int, from section: String? = nil) -> [KnowledgeQuestion] {
        return knowledgeQuestions?.randomQuestions(count: count, from: section) ?? []
    }
    
    var knowledgeQuestionSections: [String] {
        return knowledgeQuestions?.allSections ?? []
    }
    
    func knowledgeQuestions(for section: String) -> [KnowledgeQuestion] {
        return knowledgeQuestions?.questionsForSection(section) ?? []
    }
}
