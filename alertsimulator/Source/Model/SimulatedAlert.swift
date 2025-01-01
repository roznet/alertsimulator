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
    }
    
    let category : Category
    let action : Action
    let priority : Priority
    let alertType : AlertType
    let message : String?
    let description : String?
    
    var title : String {
        return "\(category) \(alertType)"
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
