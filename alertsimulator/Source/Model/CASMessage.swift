//  MIT License
//
//  Created on 04/01/2025 for alertsimulator
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

struct CASMessage {
    typealias Category = FlightAlert.Category
    
    let category: Category
    let message: String
    let submessage: String
    
    var categoryDescription: String {
        switch category {
        case .emergency: return "Warning"
        case .abnormal: return "Caution"
        case .normal: return "Alerts"
        }
    }
    
    var detailedMessage: String {
        var parts : [String] = []
        if !message.isEmpty {
            parts.append(self.message)
        }
        if !submessage.isEmpty {
            parts.append(self.submessage)
        }
        return parts.joined(separator: " - ")
    }
    
    init (category: Category = .normal, message: String = "", submessage: String = "") {
        self.category = category
        self.message = message
        self.submessage = submessage
    }
}
