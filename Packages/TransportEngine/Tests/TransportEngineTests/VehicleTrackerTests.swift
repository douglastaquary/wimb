//
//  VehicleTrackerTests.swift
//  TransportEngineTests
//

import XCTest
@testable import TransportEngine
import WIMBCore

final class VehicleTrackerTests: XCTestCase {
    func test_merge_preservesPreviousCoordinateWhenPositionChanges() {
        let existing = Vehicle(
            prefix: "74512",
            accessible: true,
            lastUpdateTime: "14:30",
            coordinate: Coordinate(latitude: -23.55, longitude: -46.63)
        )

        let incoming = Vehicle(
            prefix: "74512",
            accessible: true,
            lastUpdateTime: "14:31",
            coordinate: Coordinate(latitude: -23.56, longitude: -46.64)
        )

        let merged = VehicleTracker.merge(existing: [existing], with: [incoming])

        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(merged[0].coordinate.latitude, -23.56, accuracy: 0.0001)
        XCTAssertEqual(merged[0].previousCoordinate?.latitude ?? 0, -23.55, accuracy: 0.0001)
    }

    func test_merge_keepsExistingVehicleWhenPositionUnchanged() {
        let coordinate = Coordinate(latitude: -23.55, longitude: -46.63)
        let existing = Vehicle(
            id: UUID(),
            prefix: "74512",
            accessible: true,
            lastUpdateTime: "14:30",
            coordinate: coordinate
        )

        let incoming = Vehicle(
            prefix: "74512",
            accessible: false,
            lastUpdateTime: "14:31",
            coordinate: coordinate
        )

        let merged = VehicleTracker.merge(existing: [existing], with: [incoming])

        XCTAssertEqual(merged[0].id, existing.id)
        XCTAssertEqual(merged[0].lastUpdateTime, "14:30")
    }
}
