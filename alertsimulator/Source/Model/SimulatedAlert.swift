//
//  Alert.swift
//  alertsimulator
//
//  Created by Brice Rosenzweig on 28/12/2024.
//

import Foundation
import UserNotifications

struct SimulatedAlert : Codable {
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
        case Situation = "situation"
        
        var uniqueIdentifier: String {
            switch self {
            case .cas: return "cas"
            case .Situation: return "situ"
            }
        }
    }
    
    let category : Category
    let action : Action
    let priority : Priority
    let alertType : AlertType
    let message : String?
    let submessage : String? // to distinguish for two identical message
    let description : String?
    
    init(category: Category, action: Action, alertType: AlertType, message: String?, submessage: String? = nil, description: String? = nil, priority: Priority = .medium) {
        self.category = category
        self.action = action
        self.priority = priority
        self.alertType = alertType
        self.message = message
        self.submessage = submessage
        self.description = description
    }
    
    var title : String {
        return "\(category) \(alertType)"
    }
    
    var uniqueIdentifier: String {
        let message = self.message ?? ""
        var submessage = self.submessage ?? ""
        if !submessage.isEmpty {
           submessage = "-\(message)"
        }
        return "\(category.uniqueIdentifier)-\(alertType.uniqueIdentifier)-\(message)\(submessage)"
    }
    
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
}

extension SimulatedAlert {
    var notificationContent: UNNotificationContent {
        let content = UNMutableNotificationContent()
        
        content.title = title
        content.body = message ?? ""
        
        return content
    }
}
