//
//  TransportEngineTests.swift
//  TransportEngineTests
//

import XCTest
@testable import TransportEngine
import WIMBCore

final class TransportEngineTests: XCTestCase {
    var mockService: MockTransportService!
    var sut: TransportEngine!

    override func setUp() async throws {
        mockService = MockTransportService()
        sut = TransportEngine(client: mockService)
    }

    override func tearDown() async throws {
        await sut.stopAllTracking()
        sut = nil
        mockService = nil
    }

    func test_startTracking_addsLineToTracked() async throws {
        let lineId = 34041
        let vehicle = makeVehicle(prefix: "74512", lat: -23.55, lon: -46.63)
        await mockService.setVehiclePositions([vehicle], for: lineId)

        try await sut.startTracking(lineId: lineId)

        let tracked = await sut.trackedLines
        XCTAssertTrue(tracked.contains(lineId))
    }

    func test_stopTracking_removesLineFromTracked() async throws {
        let lineId = 34041
        await mockService.setVehiclePositions([], for: lineId)
        try await sut.startTracking(lineId: lineId)

        await sut.stopTracking(lineId: lineId)

        let tracked = await sut.trackedLines
        XCTAssertFalse(tracked.contains(lineId))
    }

    func test_allVehicles_returnsVehiclesFromAllLines() async throws {
        let vehicle1 = makeVehicle(prefix: "74512", lat: -23.55, lon: -46.63)
        let vehicle2 = makeVehicle(prefix: "74513", lat: -23.56, lon: -46.64)

        await mockService.setVehiclePositions([vehicle1], for: 34041)
        await mockService.setVehiclePositions([vehicle2], for: 34042)

        try await sut.startTracking(lineId: 34041)
        try await sut.startTracking(lineId: 34042)

        let allVehicles = await sut.allVehicles()
        XCTAssertEqual(allVehicles.count, 2)
    }

    func test_refresh_preservesPreviousCoordinate() async throws {
        let lineId = 34041
        let initial = makeVehicle(prefix: "74512", lat: -23.55, lon: -46.63)
        let updated = makeVehicle(prefix: "74512", lat: -23.56, lon: -46.64)

        await mockService.setVehiclePositions([initial], for: lineId)
        try await sut.startTracking(lineId: lineId)

        await mockService.setVehiclePositions([updated], for: lineId)
        await sut.refresh()

        let vehicles = await sut.vehicles(for: lineId)
        XCTAssertEqual(vehicles.first?.previousCoordinate?.latitude ?? 0, -23.55, accuracy: 0.0001)
        XCTAssertEqual(vehicles.first?.coordinate.latitude ?? 0, -23.56, accuracy: 0.0001)
    }

    func test_startTracking_throwsWhenMaxLinesExceeded() async throws {
        for lineId in 1...TransportEngine.maxTrackedLines {
            await mockService.setVehiclePositions([], for: lineId)
            try await sut.startTracking(lineId: lineId)
        }

        do {
            try await sut.startTracking(lineId: 999)
            XCTFail("Expected tooManyTrackedLines error")
        } catch WIMBError.tooManyTrackedLines(let max) {
            XCTAssertEqual(max, TransportEngine.maxTrackedLines)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_startTracking_usesCacheWhenNetworkFails() async throws {
        let lineId = 34041
        let cachedVehicle = makeVehicle(prefix: "74512", lat: -23.55, lon: -46.63)
        let cache = InMemoryCacheManager()
        await cache.saveVehicles([cachedVehicle], for: lineId)

        let failingService = MockTransportService()
        await failingService.setShouldFailFetch(true)

        let engine = TransportEngine(client: failingService, cacheManager: cache)
        try await engine.startTracking(lineId: lineId)

        let vehicles = await engine.vehicles(for: lineId)
        XCTAssertEqual(vehicles.count, 1)
        XCTAssertEqual(vehicles.first?.prefix, "74512")
    }

    private func makeVehicle(prefix: String, lat: Double, lon: Double) -> Vehicle {
        Vehicle(
            prefix: prefix,
            accessible: true,
            lastUpdateTime: "14:30",
            coordinate: Coordinate(latitude: lat, longitude: lon)
        )
    }
}
