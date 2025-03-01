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

typealias AlertsLoadResult = (alerts: [FlightAlert], version: String)

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
        case memory = "memory"
        
        var uniqueIdentifier: String {
            switch self {
            case .cas: return "cas"
            case .situation: return "situ"
            case .memory: return "mem"
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
    
    var fullMessage : String {
        var parts : [String] = []
        if let message = self.message {
            parts.append(message)
        }
        if let submessage = self.submessage, !submessage.isEmpty {
            parts.append(submessage)
        }
        return parts.joined(separator: " ")
    }
   
    var casMessage : CASMessage {
        if self.alertType == .cas {
            return CASMessage(category: self.category, message: self.message ?? "Alert", submessage: self.submessage ?? "")
        }else if self.alertType == .memory {
            return CASMessage(category: self.category, message: "MEMORY", submessage: self.fullMessage)
        }else{
            if let submessage = self.submessage, !submessage.isEmpty {
                return CASMessage(category: self.category, message: self.message ?? "", submessage: submessage)
            }else{
                return CASMessage(category: self.category, message: "", submessage: self.message ?? "")
            }
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
        // Try to load both bundle and local storage
        let bundleResult: AlertsLoadResult? = loadFromBundle()
        let localResult: AlertsLoadResult? = loadFromLocalStorage()
        
        // If we have both, compare versions
        if let localData = localResult,
           let bundleData = bundleResult {
            
            // Use bundle if it's more recent
            if let bundleDateVersion = versionToDate(bundleData.version),
               let localDateVersion = versionToDate(localData.version),
               bundleDateVersion > localDateVersion {
                Logger.app.info("Using bundle alerts (newer version: \(bundleData.version))")
                Settings.shared.alertsDataVersion = bundleData.version
                return bundleData.alerts
            }
            
            Logger.app.info("Using local alerts (version: \(localData.version))")
            Settings.shared.alertsDataVersion = localData.version
            return localData.alerts
        }
        
        // If we only have one or the other, use what we have
        if let localData = localResult {
            Logger.app.info("Using local alerts (no bundle comparison available)")
            Settings.shared.alertsDataVersion = localData.version
            return localData.alerts
        }
        
        // Use bundle data or empty array as last resort
        if let bundleData = bundleResult {
            Logger.app.info("Using bundle alerts (no local storage available)")
            Settings.shared.alertsDataVersion = bundleData.version
            return bundleData.alerts
        }
        
        return []
    }
    
    private static func loadAndDecodeAlertsData(from url: URL) -> AlertsLoadResult? {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let alertsData = try decoder.decode(AlertsData.self, from: data)
            return (alertsData.alerts, alertsData.version)
        } catch {
            Logger.app.error("Error decoding alerts data from \(url.path): \(error)")
            return nil
        }
    }
    
    private static func loadFromBundle() -> AlertsLoadResult? {
        guard let url = Bundle.main.url(forResource: "AlertsToSimulate", withExtension: "json") else {
            Logger.app.error("Default JSON file not found.")
            return nil
        }
        
        return loadAndDecodeAlertsData(from: url)
    }
    
    private static func loadFromLocalStorage() -> AlertsLoadResult? {
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let alertsFile = documentsPath.appendingPathComponent("AlertsToSimulate.json")
        
        guard fileManager.fileExists(atPath: alertsFile.path) else {
            return nil
        }
        
        return loadAndDecodeAlertsData(from: alertsFile)
    }
    
    private static func versionToDate(_ version: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd.HHmm"
        return formatter.date(from: version)
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
                
                // Convert versions to dates for comparison
                guard let newVersion = versionToDate(alertsData.version),
                      let currentVersion = versionToDate(Settings.shared.alertsDataVersion) else {
                    Logger.app.error("Invalid version format")
                    return
                }
                
                // Compare dates instead of strings
                if newVersion > currentVersion {
                    // Save new data
                    try self.saveNewAlertsData(data)
                    Logger.app.info("New alerts data saved")
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
