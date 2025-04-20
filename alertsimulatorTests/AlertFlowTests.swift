import Foundation
import Testing
import UserNotifications
@testable import alertsimulator

// MARK: - Mock Notification Center
class MockNotificationCenter: UserNotificationCenter {
    var delegate: (any UNUserNotificationCenterDelegate)? = nil
    
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, (any Error)?) -> Void) {
        completionHandler(true, nil)
    }
    
    var scheduledRequests: [UNNotificationRequest] = []
    var deliveredNotifications: [UNNotification] = []
    
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        scheduledRequests.append(request)
        completionHandler?(nil)
    }
    
    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void) {
        completionHandler(scheduledRequests)
    }
    
    func removeAllPendingNotificationRequests() {
        scheduledRequests.removeAll()
    }
}


struct AlertFlowTests {
    
    // MARK: - Setup
    private func setupTestEnvironment() -> (AlertManager, Flight, NotificationManager) {
        let manager = AlertManager()
        let aircraft = Aircraft(aircraftName: "SF50")
        // Use much shorter duration and interval for testing
        let flight = Flight(aircraft: aircraft, duration: 60, interval: 5) // 1 minute flight, 5 second intervals
        let mockCenter = MockNotificationCenter()
        
        let notificationManager = NotificationManager(center: mockCenter)
        
        // Reset any existing notifications
        notificationManager.cancelAll()
        
        return (manager, flight, notificationManager)
    }
    
    // MARK: - Alert Generation Tests
    @Test func testAlertGeneration() async throws {
        var (manager, _, _) = setupTestEnvironment()
        var testParameters = AlertParameters()
        testParameters.knowledgeQuestionProportion = 0.0
        // Test regular alert generation
        let regularAlert = manager.drawNextAlert(alertParameters: testParameters)
        #expect(regularAlert.uid != -2) // Not a knowledge question
        #expect(regularAlert.message != nil)
        
        // Test knowledge question generation by setting proportion to 100%
        testParameters.knowledgeQuestionProportion = 1.0
        let knowledgeAlert = manager.drawNextAlert(alertParameters: testParameters)
        #expect(knowledgeAlert.uid == -2) // Knowledge question UID
        #expect(knowledgeAlert.message?.contains("Knowledge Questions") == true)
    }
    
    @Test func testAlertScheduling() async throws {
        var (_, flight, notificationManager) = setupTestEnvironment()
        let testParameters = AlertParameters()
        // Start flight and schedule alerts
        flight.start(alertParameters: testParameters)
        notificationManager.scheduleAll(for: flight)
        
        // Get pending notifications
        let pendingAlerts = await notificationManager.getPendingNotifications()
        
        #expect(pendingAlerts.count > 0)
        
        // Verify alert dates are in the future
        for alert in pendingAlerts {
            #expect(alert.date > Date())
        }
    }
    
    // MARK: - Notification Handling Tests
    @Test func testNotificationHandling() async throws {
        var (manager, _, notificationManager) = setupTestEnvironment()
        let testParameters = AlertParameters()

        // Create a test alert
        let testAlert = manager.drawNextAlert(alertParameters: testParameters)
        let trackedAlert = TrackedAlert(date: Date().addingTimeInterval(1), alert: testAlert)

        // Schedule the alert
        notificationManager.scheduleNext(tracked: trackedAlert)

        // Listen for the notification using async sequence
        let receivedAlert: FlightAlert? = await withTaskGroup(of: FlightAlert?.self) { group in
            group.addTask {
                for await notification in NotificationCenter.default.notifications(named: .didReceiveSimulatedAlert) {
                    if let alert = notification.object as? FlightAlert {
                        return alert
                    }
                }
                return nil // fallback
            }

            // Simulate the notification (like UNUserNotificationCenter would call your delegate)
            NotificationCenter.default.post(name: .didReceiveSimulatedAlert, object: testAlert)

            return await group.next() ?? nil
        }

        #expect(receivedAlert?.uid == testAlert.uid)
    }
    
 
    // MARK: - Knowledge Question Integration Tests
    @Test func testKnowledgeQuestionIntegration() async throws {
        var (manager, _, _) = setupTestEnvironment()
        
        // Set knowledge question proportion to 50%
        let testParameters = AlertParameters(knowledgeQuestionProportion: 0.5)
        
        // Generate multiple alerts and count knowledge questions
        var knowledgeQuestionCount = 0
        var totalAlerts = 0
        
        for _ in 0..<20 {
            let alert = manager.drawNextAlert(alertParameters: testParameters)
            if alert.uid == -2 {
                knowledgeQuestionCount += 1
            }
            totalAlerts += 1
        }
        
        // Verify knowledge questions are being generated
        #expect(knowledgeQuestionCount > 0)
        
        // Verify proportion is roughly correct (within 20% of target)
        let proportion = Double(knowledgeQuestionCount) / Double(totalAlerts)
        #expect(abs(proportion - 0.5) < 0.2)
    }
    
    // MARK: - State Management Tests
    @Test func testStateManagement() async throws {
        var (_, flight, notificationManager) = setupTestEnvironment()
        let testParameters = AlertParameters()
        // Start flight
        flight.start(alertParameters: testParameters)
        notificationManager.scheduleAll(for: flight)
        
        // Stop flight
        flight.stop()
        notificationManager.cancelAll()
       
        let pendingAlerts = await notificationManager.getPendingNotifications()
        
        #expect(pendingAlerts.isEmpty)
    }
} 
