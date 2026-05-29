//
//  MetroNearbyService.swift
//  TransportEngine
//

import Foundation
import WIMBCore

/// Encontra estações de metrô próximas ao usuário.
public struct MetroNearbyService: Sendable {
    public static let walkingSpeedMetersPerMinute: Double = 80

    public init() {}

    public func nearbyStations(
        to location: Coordinate,
        limit: Int = 3,
        maxDistanceMeters: Double = 4_000
    ) -> [NearbyMetroStop] {
        let searchLocation = Self.resolvedSearchLocation(for: location)
        let results = rankedStations(
            near: searchLocation,
            limit: limit,
            maxDistanceMeters: maxDistanceMeters
        )

        guard results.isEmpty else { return results }

        // Fallback: centro de SP (Sé) quando GPS está longe ou simulador fora da região.
        return rankedStations(
            near: Coordinate.saoPauloDefault,
            limit: limit,
            maxDistanceMeters: maxDistanceMeters
        )
    }

    /// Usa GPS só dentro da região metropolitana; senão Sé.
    static func resolvedSearchLocation(for location: Coordinate) -> Coordinate {
        isInSaoPauloMetroRegion(location) ? location : Coordinate.saoPauloDefault
    }

    static func isInSaoPauloMetroRegion(_ coordinate: Coordinate) -> Bool {
        coordinate.latitude >= -24.05
            && coordinate.latitude <= -23.25
            && coordinate.longitude >= -47.05
            && coordinate.longitude <= -46.25
    }

    private func rankedStations(
        near location: Coordinate,
        limit: Int,
        maxDistanceMeters: Double
    ) -> [NearbyMetroStop] {
        MetroStationCatalog.stations
            .map { station in
                let distance = location.distance(to: station.coordinate)
                let walkingMinutes = max(1, Int((distance / Self.walkingSpeedMetersPerMinute).rounded()))
                return NearbyMetroStop(
                    station: station,
                    distanceMeters: distance,
                    walkingMinutes: walkingMinutes
                )
            }
            .filter { $0.distanceMeters <= maxDistanceMeters }
            .sorted { $0.distanceMeters < $1.distanceMeters }
            .prefix(limit)
            .map { $0 }
    }
}
