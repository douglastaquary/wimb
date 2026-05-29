//
//  NearbyStopsFilter.swift
//  WIMBCore
//

import Foundation

/// Filtra e ordena paradas por proximidade.
public enum NearbyStopsFilter {
    public static func filter(
        _ stops: [Stop],
        near coordinate: Coordinate,
        radiusMeters: Double = 800
    ) -> [Stop] {
        stops
            .filter { $0.coordinate.distance(to: coordinate) <= radiusMeters }
            .sorted { lhs, rhs in
                lhs.coordinate.distance(to: coordinate) < rhs.coordinate.distance(to: coordinate)
            }
    }
}
