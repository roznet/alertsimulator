//
//  alertsimulatorTests.swift
//  alertsimulatorTests
//
//  Created by Brice Rosenzweig on 28/12/2024.
//

import Testing
@testable import alertsimulator

struct alertsimulatorTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        
        let manager = AlertManager()
        #expect(manager.available.count > 0)
    }

}
