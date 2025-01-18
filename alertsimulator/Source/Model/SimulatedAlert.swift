//
//  Alert.swift
//  alertsimulator
//
//  Created by Brice Rosenzweig on 28/12/2024.
//

import Foundation
import UserNotifications

struct SimulatedAlert : Codable, CustomStringConvertible {
    enum Category : String, Codable {
        case abnormal = "abnormal"
        case emergency = "emergency"
        case normal = "normal"
        
        var uniqueIdentifier: String {
            switch self {
            case .abnormal: return "ab"
            case .emergency: return "em"
            case .normal: return "no"
            }
        }
    }
    
    enum Action : String, Codable {
        case simulate = "simulate"
        case ignore = "ignore"
        case review = "review"
    }
    
    enum Priority : String, Codable {
        case high = "high"
        case medium = "medium"
        case low = "low"
        case none = "none"
    }
    
    enum AlertType : String, Codable {
        case cas = "cas"
        case situation = "situation"
        
        var uniqueIdentifier: String {
            switch self {
            case .cas: return "cas"
            case .situation: return "situ"
            }
        }
    }
    
    let category : Category
    let action : Action
    let priority : Priority
    let alertType : AlertType
    let message : String?
    let submessage : String? // to distinguish for two identical message
    let uid : Int
    
    let aircraft : String
    
    var description: String {
       var parts: [String] = [
        "uid: \(uid)",
        "category: .\(category)",
        "action: .\(action)",
        "priority: .\(priority)",
        "alertType: .\(alertType)",
        ]
        if let message = message {
            parts.append("message: \"\(message)\"")
        }
        if let submessage = submessage, !submessage.isEmpty {
            parts.append("submessage: \"\(submessage)\"")
        }
        return "SimulatedAlert(" + parts.joined(separator: ", ") + ")"
    }
    init(category: Category, action: Action, alertType: AlertType, message: String?, uid : Int, submessage: String? = nil, priority: Priority = .medium, aircraft: String = "") {
        self.category = category
        self.action = action
        self.priority = priority
        self.alertType = alertType
        self.message = message
        self.submessage = submessage
        self.uid = uid
        self.aircraft = aircraft
    }
    
    var title : String {
        return "\(category) \(alertType)"
    }
   
    var casMessage : CASMessage {
        if self.alertType == .cas {
            return CASMessage(category: self.category, message: self.message ?? "Alert", submessage: self.submessage ?? "")
        }else{
            return CASMessage(category: self.category, message: "", submessage: self.message ?? "")
        }
    }
    var uniqueIdentifier: String {
        var vals : [String] = ["\(self.uid)", category.uniqueIdentifier, alertType.uniqueIdentifier]
        if let message = message {
            vals.append(message)
        }

        return vals.joined(separator: "-")
    }
    
    static var aircrafts : [String] = {
        return Set(Self.available.map { $0.aircraft }).sorted()
    }()
    
    static var available: [SimulatedAlert] = {
            // Attempt to load and decode the JSON file
            guard let url = Bundle.main.url(forResource: "AlertsToSimulate", withExtension: "json") else {
                print("Default JSON file not found.")
                return []
            }
            
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                return try decoder.decode([SimulatedAlert].self, from: data)
            } catch {
                print("Error decoding JSON: \(error)")
                return []
            }
        }()
    static func alert(for uniqueIdentifier: String) -> SimulatedAlert? {
        for alert in available where alert.uniqueIdentifier == uniqueIdentifier {
            return alert
        }
        return nil
    }
}

extension SimulatedAlert {
    var notificationContent: UNNotificationContent {
        let content = UNMutableNotificationContent()
        
        content.title = title
        content.body = message ?? ""
        
        return content
    }
}
