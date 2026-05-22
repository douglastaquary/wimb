//
//  LiveTrackingMetrics.swift
//  Shared
//

import Foundation
import TransportEngine
import WIMBCore

struct LiveTrackingSnapshot {
    let vehicle: Vehicle
    let stopsAway: Int
    let etaMinutes: Int
    let referenceStop: Stop?
}

enum LiveTrackingMetrics {
    static func snapshot(
        stops: [Stop],
        vehicles: [Vehicle],
        userLocation: Coordinate?,
        etaMinutes: (Vehicle, Stop) -> Int
    ) -> LiveTrackingSnapshot? {
        guard !stops.isEmpty, !vehicles.isEmpty else { return nil }

        let referenceIndex = referenceStopIndex(stops: stops, userLocation: userLocation)
        let referenceStop = stops[safe: referenceIndex]

        guard
            let vehicle = closestVehicle(
                vehicles: vehicles,
                stops: stops,
                referenceIndex: referenceIndex
            ),
            let vehicleStopIndex = nearestStopIndex(to: vehicle.coordinate, in: stops)
        else {
            return nil
        }

        let stopsAway = max(0, referenceIndex - vehicleStopIndex)
        let eta = etaMinutes(vehicle, stops[vehicleStopIndex])

        return LiveTrackingSnapshot(
            vehicle: vehicle,
            stopsAway: stopsAway,
            etaMinutes: eta,
            referenceStop: referenceStop
        )
    }

    private static func referenceStopIndex(stops: [Stop], userLocation: Coordinate?) -> Int {
        if let userLocation = userLocation,
           let index = nearestStopIndex(to: userLocation, in: stops) {
            return index
        }

        return stops.firstIndex(where: \.hasVehicles) ?? 0
    }

    private static func closestVehicle(
        vehicles: [Vehicle],
        stops: [Stop],
        referenceIndex: Int
    ) -> Vehicle? {
        vehicles.min { lhs, rhs in
            let lhsIndex = nearestStopIndex(to: lhs.coordinate, in: stops) ?? 0
            let rhsIndex = nearestStopIndex(to: rhs.coordinate, in: stops) ?? 0
            return abs(referenceIndex - lhsIndex) < abs(referenceIndex - rhsIndex)
        }
    }

    private static func nearestStopIndex(to coordinate: Coordinate, in stops: [Stop]) -> Int? {
        guard !stops.isEmpty else { return nil }

        var bestIndex = 0
        var bestDistance = Double.greatestFiniteMagnitude

        for (index, stop) in stops.enumerated() {
            let distance = coordinate.distance(to: stop.coordinate)
            if distance < bestDistance {
                bestDistance = distance
                bestIndex = index
            }
        }

        return bestIndex
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
