//
//  Alert.swift
//  alertsimulator
//
//  Created by Brice Rosenzweig on 28/12/2024.
//

import Foundation
import UserNotifications
import OSLog

struct AlertsData: Codable {
    let version: String
    let alerts: [FlightAlert]
}

struct FlightAlert : Codable, CustomStringConvertible {
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
    let aircraftName : String?
    let submessage : String? // to distinguish for two identical message
    let uid : Int
    
    var aircraft : Aircraft? {
        guard let aircraftName = self.aircraftName else { return nil }
        return Aircraft(aircraftName: aircraftName)
    }
    
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
    init(category: Category, action: Action, alertType: AlertType, message: String?, uid : Int, submessage: String? = nil, priority: Priority = .medium, aircraftName: String = "") {
        self.category = category
        self.action = action
        self.priority = priority
        self.alertType = alertType
        self.message = message
        self.submessage = submessage
        self.uid = uid
        self.aircraftName = aircraftName
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
    
    static var aircrafts : [Aircraft] = {
        return Set(Self.available.compactMap { $0.aircraftName }).sorted().map { Aircraft(aircraftName: $0)}
    }()
   
    static func availableFor(aircraft : Aircraft) -> [FlightAlert] {
        let alertsForAircraft : [FlightAlert] = Self.available.filter { $0.aircraft == aircraft }
        return alertsForAircraft
    }

    private static var available: [FlightAlert] = {
        loadAlerts()
    }()

    private static func loadAlerts() -> [FlightAlert] {
        // First try to load from local storage
        if let localAlerts = loadFromLocalStorage() {
            return localAlerts
        }
        
        // If no local storage, load from bundle
        return loadFromBundle()
    }
    
    private static func loadFromBundle() -> [FlightAlert] {
        guard let url = Bundle.main.url(forResource: "AlertsToSimulate", withExtension: "json") else {
            Logger.app.error("Default JSON file not found.")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let alertsData = try decoder.decode(AlertsData.self, from: data)
            Settings.shared.alertsDataVersion = alertsData.version
            return alertsData.alerts
        } catch {
            Logger.app.error("Error decoding bundle JSON: \(error)")
            return []
        }
    }
    
    private static func loadFromLocalStorage() -> [FlightAlert]? {
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let alertsFile = documentsPath.appendingPathComponent("AlertsToSimulate.json")
        
        guard fileManager.fileExists(atPath: alertsFile.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: alertsFile)
            let decoder = JSONDecoder()
            let alertsData = try decoder.decode(AlertsData.self, from: data)
            Settings.shared.alertsDataVersion = alertsData.version
            return alertsData.alerts
        } catch {
            Logger.app.error("Error loading local alerts: \(error)")
            return nil
        }
    }
    
    static func checkForUpdates() {
        guard Settings.shared.shouldCheckForUpdates else { return }
        
        guard let url = URL(string: Settings.shared.alertsDataUrl) else {
            Logger.app.error("Invalid alerts data URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                Logger.app.error("Error checking for updates: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let data = data else {
                Logger.app.error("Invalid response or no data")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let alertsData = try decoder.decode(AlertsData.self, from: data)
                
                // Compare versions
                if alertsData.version > Settings.shared.alertsDataVersion {
                    // Save new data
                    try self.saveNewAlertsData(data)
                    // Reload alerts
                    self.available = alertsData.alerts
                    Settings.shared.alertsDataVersion = alertsData.version
                }
                
                // Update last check time
                Settings.shared.lastUpdateCheck = Date()
                
            } catch {
                Logger.app.error("Error processing update data: \(error)")
            }
        }
        
        task.resume()
    }
    
    private static func saveNewAlertsData(_ data: Data) throws {
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "FlightAlert", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not access documents directory"])
        }
        
        let alertsFile = documentsPath.appendingPathComponent("AlertsToSimulate.json")
        
        // Create a backup of the current file if it exists
        if fileManager.fileExists(atPath: alertsFile.path) {
            let backupFile = documentsPath.appendingPathComponent("AlertsToSimulate.backup.json")
            try? fileManager.removeItem(at: backupFile)
            try fileManager.copyItem(at: alertsFile, to: backupFile)
        }
        
        // Write new data
        try data.write(to: alertsFile)
    }
    
    static func alert(for uniqueIdentifier: String) -> FlightAlert? {
        for alert in available where alert.uniqueIdentifier == uniqueIdentifier {
            return alert
        }
        return nil
    }
}

extension FlightAlert {
    var notificationContent: UNNotificationContent {
        let content = UNMutableNotificationContent()
        
        content.title = title
        content.body = message ?? ""
        content.sound = UNNotificationSound.default
        
        return content
    }
}
