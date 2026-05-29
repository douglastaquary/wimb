//
//  RouteLineBuilder.swift
//  MapFeature
//

import CoreLocation
import Foundation
import WIMBCore

/// Monta polilinha da rota a partir de paradas e posições de veículos.
enum RouteLineBuilder {
    /// Coordenadas da rota na ordem retornada pela API de chegadas.
    static func routeCoordinates(stops: [Stop], vehicles: [Vehicle]) -> [CLLocationCoordinate2D] {
        let stopCoordinates = stops.map { $0.coordinate.clCoordinate }

        guard stopCoordinates.count >= 2 else {
            return fallback(from: vehicles, minimum: 2)
        }

        return deduplicated(stopCoordinates)
    }

    /// Todas as coordenadas relevantes para enquadrar o mapa (rota + ônibus + paradas).
    static func framingCoordinates(
        stops: [Stop],
        vehicles: [Vehicle],
        vehicleDisplay: [CLLocationCoordinate2D]
    ) -> [CLLocationCoordinate2D] {
        var all = routeCoordinates(stops: stops, vehicles: vehicles)
        all.append(contentsOf: vehicleDisplay)
        all.append(contentsOf: stops.map { $0.coordinate.clCoordinate })
        return deduplicated(all)
    }

    private static func fallback(from vehicles: [Vehicle], minimum: Int) -> [CLLocationCoordinate2D] {
        let coords = vehicles.map { $0.coordinate.clCoordinate }
        guard coords.count >= minimum else { return coords }
        return deduplicated(coords)
    }

    private static func deduplicated(_ coordinates: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
        var result: [CLLocationCoordinate2D] = []
        for coordinate in coordinates {
            guard let last = result.last else {
                result.append(coordinate)
                continue
            }
            if abs(last.latitude - coordinate.latitude) > 0.00001
                || abs(last.longitude - coordinate.longitude) > 0.00001 {
                result.append(coordinate)
            }
        }
        return result
    }
}
