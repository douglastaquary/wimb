//
//  NearbyStopsServiceTests.swift
//  TransportEngineTests
//

import XCTest
@testable import TransportEngine
import WIMBCore

final class NearbyStopsServiceTests: XCTestCase {
    func test_fetchNearbyStops_filtersWithinRadius() async throws {
        let mock = MockTransportService()
        let center = Coordinate.saoPauloDefault
        let near = Stop(
            id: 1,
            name: "Perto",
            coordinate: Coordinate(latitude: center.latitude + 0.002, longitude: center.longitude)
        )
        let far = Stop(
            id: 2,
            name: "Longe",
            coordinate: Coordinate(latitude: -23.60, longitude: -46.70)
        )

        await mock.setSearchStops([near, far])

        let client: TransportService = mock
        let results = try await client.fetchNearbyStops(
            near: center,
            query: "Paulista",
            radiusMeters: 800
        )

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.id, near.id)
    }

    func test_nearbyStopsFilter_sortsByDistance() {
        let center = Coordinate.saoPauloDefault
        let closer = Stop(
            id: 10,
            name: "Mais perto",
            coordinate: Coordinate(latitude: center.latitude + 0.001, longitude: center.longitude)
        )
        let farther = Stop(
            id: 11,
            name: "Mais longe",
            coordinate: Coordinate(latitude: center.latitude + 0.004, longitude: center.longitude)
        )

        let filtered = NearbyStopsFilter.filter(
            [farther, closer],
            near: center,
            radiusMeters: 800
        )

        XCTAssertEqual(filtered.map(\.id), [closer.id, farther.id])
    }
}
