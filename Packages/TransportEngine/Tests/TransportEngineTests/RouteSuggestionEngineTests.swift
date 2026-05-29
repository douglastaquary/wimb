//
//  RouteSuggestionEngineTests.swift
//  TransportEngineTests
//

import XCTest
@testable import TransportEngine
import WIMBCore

final class RouteSuggestionEngineTests: XCTestCase {
    func test_suggest_returnsSortedRoutes() async throws {
        let mock = MockTransportService()
        let line = TransportLine.mock
        let origin = Coordinate.saoPauloDefault
        let destination = Coordinate(latitude: -23.56, longitude: -46.64)

        let boarding = Stop(
            id: 100,
            name: "Parada origem",
            coordinate: Coordinate(latitude: -23.5507, longitude: -46.6335)
        )
        let middle = Stop(
            id: 101,
            name: "Parada meio",
            coordinate: Coordinate(latitude: -23.555, longitude: -46.638)
        )
        let alighting = Stop(
            id: 102,
            name: "Parada destino",
            coordinate: Coordinate(latitude: -23.5598, longitude: -46.6398)
        )

        await mock.setSearchStops([boarding])
        await mock.setStopDetail(
            StopDetail(stop: boarding, lines: [StopLineForecast(line: line, vehicles: [])]),
            for: boarding.id
        )
        await mock.setArrivals([boarding, middle, alighting], for: line.id)

        let engine = RouteSuggestionEngine(client: mock)
        let suggestions = try await engine.suggest(from: origin, to: destination)

        XCTAssertFalse(suggestions.isEmpty)
        XCTAssertEqual(suggestions.first?.line.id, line.id)
        XCTAssertEqual(suggestions.first?.boardingStop.id, boarding.id)
        XCTAssertEqual(suggestions.first?.alightingStop.id, alighting.id)
        XCTAssertLessThanOrEqual(suggestions.count, RouteSuggestionEngine.maxSuggestions)
    }

    func test_suggest_returnsEmptyWhenNoCandidateLines() async throws {
        let mock = MockTransportService()
        await mock.setSearchStops([])

        let engine = RouteSuggestionEngine(client: mock)
        let suggestions = try await engine.suggest(
            from: Coordinate.saoPauloDefault,
            to: Coordinate(latitude: -23.58, longitude: -46.66)
        )

        XCTAssertTrue(suggestions.isEmpty)
    }
}
